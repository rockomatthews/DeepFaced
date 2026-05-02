-- Reference schema for a Vercel-hosted Supabase project.
-- Apply through the Supabase dashboard or CLI after linking the production project.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.creator_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  handle text not null unique,
  display_name text not null,
  bio text not null default '',
  website_url text,
  avatar_path text,
  avatar_gradient text not null default 'linear-gradient(135deg, #22d3ee, #7c3aed)',
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint creator_profiles_handle_format check (handle ~ '^[a-z0-9][a-z0-9_-]{2,29}$')
);

alter table public.creator_profiles
  add column if not exists bio text not null default '',
  add column if not exists website_url text,
  add column if not exists avatar_path text,
  add column if not exists updated_at timestamptz not null default now();

drop trigger if exists set_creator_profiles_updated_at on public.creator_profiles;
create trigger set_creator_profiles_updated_at
  before update on public.creator_profiles
  for each row
  execute function public.set_updated_at();

alter table public.creator_profiles enable row level security;

drop policy if exists "Creator profiles are publicly readable" on public.creator_profiles;
create policy "Creator profiles are publicly readable"
  on public.creator_profiles
  for select
  using (true);

drop policy if exists "Users can create their creator profile" on public.creator_profiles;
create policy "Users can create their creator profile"
  on public.creator_profiles
  for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists "Users can update their creator profile" on public.creator_profiles;
create policy "Users can update their creator profile"
  on public.creator_profiles
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create table if not exists public.face_effects (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.creator_profiles (id) on delete cascade,
  slug text not null unique,
  name text not null,
  effect_kind text not null default 'face',
  category text not null,
  description text not null,
  visibility text not null default 'private',
  review_status text not null default 'draft',
  asset_path text not null,
  thumbnail_path text,
  preview_video_path text,
  source_project_path text,
  package_size_mb numeric(8, 2) not null default 0,
  deepar_studio_version text not null default 'DeepAR Studio 5.x',
  deepar_feature_flags text[] not null default '{}',
  compatible_platforms text[] not null default '{macos,web}',
  template_parameters jsonb not null default '{}'::jsonb,
  license_source text not null,
  license_label text not null,
  attribution_required boolean not null default false,
  consent_required boolean not null default false,
  consent_statement text,
  moderation_notes text,
  max_texture_size integer not null default 512,
  max_texture_size_hard_limit integer not null default 2048,
  max_polygons_per_mesh integer not null default 25000,
  max_polygons_total integer not null default 100000,
  max_scene_objects integer not null default 50,
  target_fps integer not null default 30,
  tags text[] not null default '{}',
  download_count integer not null default 0,
  try_on_count integer not null default 0,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint face_effects_slug_format check (slug ~ '^[a-z0-9][a-z0-9-]{2,79}$'),
  constraint face_effects_kind_check check (effect_kind in ('face', 'face-wearable', 'glasses', 'background', 'beauty-preset', 'wrist-wearable', 'foot-wearable', 'other')),
  constraint face_effects_visibility_check check (visibility in ('private', 'unlisted', 'public')),
  constraint face_effects_review_status_check check (review_status in ('draft', 'pending-review', 'approved', 'rejected')),
  constraint face_effects_target_fps_check check (target_fps in (24, 30, 60)),
  constraint face_effects_public_requires_approval check (visibility <> 'public' or review_status = 'approved')
);

alter table public.face_effects
  add column if not exists status text,
  add column if not exists effect_kind text not null default 'face',
  add column if not exists visibility text not null default 'private',
  add column if not exists review_status text not null default 'draft',
  add column if not exists preview_video_path text,
  add column if not exists source_project_path text,
  add column if not exists deepar_feature_flags text[] not null default '{}',
  add column if not exists compatible_platforms text[] not null default '{macos,web}',
  add column if not exists template_parameters jsonb not null default '{}'::jsonb,
  add column if not exists moderation_notes text,
  add column if not exists max_texture_size_hard_limit integer not null default 2048,
  add column if not exists max_polygons_per_mesh integer not null default 25000,
  add column if not exists max_polygons_total integer not null default 100000,
  add column if not exists max_scene_objects integer not null default 50,
  add column if not exists updated_at timestamptz not null default now();

update public.face_effects
set
  visibility = case when status = 'published' then 'public' else visibility end,
  review_status = case
    when status = 'published' then 'approved'
    when status = 'pending-review' then 'pending-review'
    when status = 'rejected' then 'rejected'
    else review_status
  end
where status is not null;

create index if not exists face_effects_creator_id_idx on public.face_effects (creator_id);
create index if not exists face_effects_public_idx on public.face_effects (published_at desc)
  where visibility = 'public' and review_status = 'approved';
create index if not exists face_effects_tags_idx on public.face_effects using gin (tags);
create index if not exists face_effects_feature_flags_idx on public.face_effects using gin (deepar_feature_flags);

drop trigger if exists set_face_effects_updated_at on public.face_effects;
create trigger set_face_effects_updated_at
  before update on public.face_effects
  for each row
  execute function public.set_updated_at();

alter table public.face_effects enable row level security;

drop policy if exists "Published faces are readable by everyone" on public.face_effects;
create policy "Published faces are readable by everyone"
  on public.face_effects
  for select
  using (visibility = 'public' and review_status = 'approved');

drop policy if exists "Creators can read their own faces" on public.face_effects;
create policy "Creators can read their own faces"
  on public.face_effects
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.creator_profiles
      where creator_profiles.id = face_effects.creator_id
        and creator_profiles.user_id = auth.uid()
    )
  );

drop policy if exists "Creators can submit faces" on public.face_effects;
create policy "Creators can submit faces"
  on public.face_effects
  for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.creator_profiles
      where creator_profiles.id = face_effects.creator_id
        and creator_profiles.user_id = auth.uid()
    )
  );

drop policy if exists "Creators can update their draft faces" on public.face_effects;
create policy "Creators can update their draft faces"
  on public.face_effects
  for update
  to authenticated
  using (
    review_status in ('draft', 'pending-review', 'rejected')
    and exists (
      select 1
      from public.creator_profiles
      where creator_profiles.id = face_effects.creator_id
        and creator_profiles.user_id = auth.uid()
    )
  )
  with check (
    review_status in ('draft', 'pending-review', 'rejected')
    and exists (
      select 1
      from public.creator_profiles
      where creator_profiles.id = face_effects.creator_id
        and creator_profiles.user_id = auth.uid()
    )
  );

drop policy if exists "Creators can delete private faces" on public.face_effects;
create policy "Creators can delete private faces"
  on public.face_effects
  for delete
  to authenticated
  using (
    visibility <> 'public'
    and exists (
      select 1
      from public.creator_profiles
      where creator_profiles.id = face_effects.creator_id
        and creator_profiles.user_id = auth.uid()
    )
  );

create table if not exists public.effect_reports (
  id uuid primary key default gen_random_uuid(),
  effect_id uuid not null references public.face_effects (id) on delete cascade,
  reporter_user_id uuid references auth.users (id) on delete set null,
  reason text not null,
  details text not null default '',
  created_at timestamptz not null default now(),
  constraint effect_reports_reason_check check (reason in ('broken-effect', 'copyright', 'unsafe-content', 'impersonation', 'other'))
);

alter table public.effect_reports enable row level security;

drop policy if exists "Authenticated users can report effects" on public.effect_reports;
create policy "Authenticated users can report effects"
  on public.effect_reports
  for insert
  to authenticated
  with check (reporter_user_id = auth.uid());

drop policy if exists "Reporters can read their own reports" on public.effect_reports;
create policy "Reporters can read their own reports"
  on public.effect_reports
  for select
  to authenticated
  using (reporter_user_id = auth.uid());

do $$
begin
  if to_regclass('storage.buckets') is not null then
    insert into storage.buckets (id, name, public)
    values ('face-effects', 'face-effects', true)
    on conflict (id) do nothing;
  else
    raise notice 'Supabase Storage is not initialized. Create a public "face-effects" bucket in the Supabase Storage dashboard.';
  end if;
end $$;

do $$
begin
  if to_regclass('storage.objects') is not null then
    drop policy if exists "Face effect files are publicly readable" on storage.objects;
    create policy "Face effect files are publicly readable"
      on storage.objects
      for select
      using (bucket_id = 'face-effects');

    drop policy if exists "Creators can upload to their own effect prefix" on storage.objects;
    create policy "Creators can upload to their own effect prefix"
      on storage.objects
      for insert
      to authenticated
      with check (
        bucket_id = 'face-effects'
        and (
          name like ('profiles/' || auth.uid()::text || '/%')
          or name like ('effects/' || auth.uid()::text || '/%')
        )
      );

    drop policy if exists "Creators can update their own effect files" on storage.objects;
    create policy "Creators can update their own effect files"
      on storage.objects
      for update
      to authenticated
      using (
        bucket_id = 'face-effects'
        and (
          name like ('profiles/' || auth.uid()::text || '/%')
          or name like ('effects/' || auth.uid()::text || '/%')
        )
      )
      with check (
        bucket_id = 'face-effects'
        and (
          name like ('profiles/' || auth.uid()::text || '/%')
          or name like ('effects/' || auth.uid()::text || '/%')
        )
      );
  else
    raise notice 'Supabase Storage objects table is not initialized. Add storage policies after enabling Storage.';
  end if;
end $$;
