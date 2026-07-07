-- ============================================================
-- BMAS Keuangan — Skema Supabase
-- Jalankan seluruh isi file ini di: Supabase Dashboard > SQL Editor > New Query > Run
-- ============================================================

create table if not exists kv_store (
  key text primary key,
  value jsonb not null,
  shared boolean not null default false,
  updated_at timestamptz not null default now()
);

-- Aktifkan Row Level Security
alter table kv_store enable row level security;

-- Izinkan akses baca & tulis penuh lewat anon key (aplikasi sudah punya login sendiri).
-- Kalau nanti mau lebih ketat, ganti policy ini pakai Supabase Auth.
create policy "allow all for anon" on kv_store
  for all
  using (true)
  with check (true);

-- Trigger biar updated_at otomatis ke-update tiap kali data berubah
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_kv_store_updated_at on kv_store;
create trigger trg_kv_store_updated_at
  before update on kv_store
  for each row execute function set_updated_at();
