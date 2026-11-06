-- Barber Club: run in Supabase SQL editor once the project is active.
create extension if not exists btree_gist;
create table if not exists public.barber_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.barber_admins enable row level security;
revoke all on public.barber_admins from anon, authenticated;
create table if not exists public.barber_bookings (
 id uuid primary key default gen_random_uuid(),
 customer_name text not null check(length(trim(customer_name)) between 2 and 80),
 customer_phone text not null check(customer_phone ~ '^[0-9]{10,13}$'),
 service text not null check(service in ('corte','barba','combo')),
 barber text not null check(barber in ('Profissional 1','Profissional 2')),
 starts_at timestamptz not null,
 ends_at timestamptz not null,
 status text not null default 'pending' check(status in ('pending','confirmed','cancelled')),
 created_at timestamptz not null default now(),
 check(ends_at > starts_at),
 constraint no_overlapping_active_bookings exclude using gist
 (barber with =, tstzrange(starts_at,ends_at,'[)') with &&)
 where(status in ('pending','confirmed'))
);
create index if not exists barber_bookings_starts_idx on public.barber_bookings(starts_at);
alter table public.barber_bookings enable row level security;
revoke all on public.barber_bookings from anon, authenticated;
grant select, update on public.barber_bookings to authenticated;
create policy "admins read bookings" on public.barber_bookings for select to authenticated
 using(exists(select 1 from public.barber_admins where user_id=(select auth.uid())));
create policy "admins update bookings" on public.barber_bookings for update to authenticated
 using(exists(select 1 from public.barber_admins where user_id=(select auth.uid())))
 with check(exists(select 1 from public.barber_admins where user_id=(select auth.uid())));
-- Public API exposes only occupied time slots, never client details.
create or replace function public.barber_busy_slots(p_day date,p_barber text)
returns table(starts_at timestamptz,ends_at timestamptz)
language sql security definer set search_path = ''
as $$select b.starts_at,b.ends_at from public.barber_bookings b
where b.barber=p_barber and b.status in ('pending','confirmed')
and b.starts_at >= (p_day::timestamp at time zone 'America/Sao_Paulo')
and b.starts_at < ((p_day+1)::timestamp at time zone 'America/Sao_Paulo')$$;
revoke all on function public.barber_busy_slots(date,text) from public;
grant execute on function public.barber_busy_slots(date,text) to anon,authenticated;
-- Public booking requests are validated server-side, with no direct table access.
create or replace function public.barber_request_booking(p_name text,p_phone text,p_service text,p_barber text,p_day date,p_time text)
returns uuid language plpgsql security definer set search_path = ''
as $$
declare st timestamptz; et timestamptz; dur int; booking_id uuid;
begin
 if p_name is null or length(trim(p_name)) not between 2 and 80
 or p_phone !~ '^[0-9]{10,13}$'
 or p_service not in ('corte','barba','combo')
 or p_barber not in ('Profissional 1','Profissional 2')
 or p_time !~ '^(09|1[0-8]):(00|30)$' then
  raise exception 'Dados inválidos';
 end if;
 dur:=case when p_service='combo' then 60 else 30 end;
 st:=(p_day::text||' '||p_time)::timestamp at time zone 'America/Sao_Paulo';
 et:=st+make_interval(mins=>dur);
 if st <= now() or (et at time zone 'America/Sao_Paulo')::date<>p_day
 or (et at time zone 'America/Sao_Paulo')::time > time '19:00'
 or p_day > (now() at time zone 'America/Sao_Paulo')::date+60 then
 raise exception 'Data ou horário indisponível';
 end if;
 insert into public.barber_bookings(customer_name,customer_phone,service,barber,starts_at,ends_at)
 values(trim(p_name),p_phone,p_service,p_barber,st,et) returning id into booking_id;
 return booking_id;
exception when exclusion_violation then raise exception 'Horário ocupado';
end;$$;
revoke all on function public.barber_request_booking(text,text,text,text,date,text) from public;
grant execute on function public.barber_request_booking(text,text,text,text,date,text) to anon,authenticated;
-- After creating your admin account, grant admin access in the SQL editor:
-- insert into public.barber_admins(user_id) values ('YOUR_AUTH_USER_UUID');
