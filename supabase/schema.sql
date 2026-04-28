-- Reference schema for a Vercel-hosted Supabase project.
-- Apply through the Supabase dashboard or CLI after linking the production project.

create table if not exists public.creator_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  handle text not null unique,
  display_name text not null,
  avatar_gradient text not null default 'linear-gradient(135deg, #22d3ee, #7c3aed)',
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.creator_profiles enable row level security;

create policy "Creator profiles are publicly readable"
  on public.creator_profiles
  for select
  using (true);

create policy "Users can create their creator profile"
  on public.creator_profiles
  for insert
  to authenticated
  with check (user_id = auth.uid());

create table if not exists public.face_effects (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.creator_profiles (id) on delete cascade,
  slug text not null unique,
  name text not null,
  category text not null,
  description text not null,
  status text not null default 'pending-review',
  asset_path text not null,
  thumbnail_path text,
  package_size_mb numeric(8, 2) not null default 0,
  deepar_studio_version text not null default 'DeepAR Studio 5.x',
  license_source text not null,
  license_label text not null,
  attribution_required boolean not null default false,
  consent_required boolean not null default false,
  consent_statement text,
  max_texture_size integer not null default 1024,
  max_triangles integer not null default 12000,
  target_fps integer not null default 30,
  tags text[] not null default '{}',
  download_count integer not null default 0,
  try_on_count integer not null default 0,
  published_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.face_effects enable row level security;

create policy "Published faces are readable by everyone"
  on public.face_effects
  for select
  using (status = 'published');

create policy "Creators can read their own faces"
  on public.face_effects
  for select
  using (
    exists (
      select 1
      from public.creator_profiles
      where creator_profiles.id = face_effects.creator_id
        and creator_profiles.user_id = auth.uid()
    )
  );

create policy "Creators can submit faces"
  on public.face_effects
  for insert
  with check (
    exists (
      select 1
      from public.creator_profiles
      where creator_profiles.id = face_effects.creator_id
        and creator_profiles.user_id = auth.uid()
    )
  );

insert into storage.buckets (id, name, public)
values ('face-effects', 'face-effects', true)
on conflict (id) do nothing;

create policy "Published effect packages are public"
  on storage.objects
  for select
  using (bucket_id = 'face-effects');

create policy "Authenticated creators can upload effect packages"
  on storage.objects
  for insert
  to authenticated
  with check (bucket_id = 'face-effects');
