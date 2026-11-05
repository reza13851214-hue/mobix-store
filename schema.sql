-- اجرا در Supabase Dashboard > SQL Editor
create extension if not exists pgcrypto;
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.admin_users where user_id=auth.uid()); $$;
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(), name text not null check(length(name) between 2 and 160),
 description text, price numeric(14,0) not null check(price>=0), stock integer not null default 0 check(stock>=0),
 image_url text, active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(), customer_name text not null, phone text not null,
 address text not null, items jsonb not null, total numeric(14,0) not null check(total>=0),
 status text not null default 'new' check(status in ('new','processing','sent','done','cancelled')),
 created_at timestamptz not null default now()
);
alter table public.admin_users enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
drop policy if exists "admins can view admin list" on public.admin_users;
create policy "admins can view admin list" on public.admin_users for select to authenticated using (public.is_admin());
drop policy if exists "public reads active products" on public.products;
create policy "public reads active products" on public.products for select to anon, authenticated using (active or public.is_admin());
drop policy if exists "admins manage products" on public.products;
create policy "admins manage products" on public.products for all to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "public creates orders" on public.orders;
create policy "public creates orders" on public.orders for insert to anon, authenticated with check (true);
drop policy if exists "admins read orders" on public.orders;
create policy "admins read orders" on public.orders for select to authenticated using (public.is_admin());
drop policy if exists "admins update orders" on public.orders;
create policy "admins update orders" on public.orders for update to authenticated using (public.is_admin()) with check (public.is_admin());
-- مدیر ابتدا باید در Authentication > Users ساخته شود؛ سپس UUID او را در دستور زیر قرار دهید:
-- insert into public.admin_users(user_id) values ('UUID-OF-ADMIN');
