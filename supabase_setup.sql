-- ==============================================================================
-- Supabase Schema & Security Setup for Santanu Saha's Travel Stories
-- ==============================================================================
-- Instructions:
-- 1. Open your Supabase project dashboard (https://supabase.com/dashboard)
-- 2. Click "SQL Editor" in the left sidebar
-- 3. Paste this entire script and click "Run"
-- ==============================================================================

-- 1. Create the travel_stories table
create table if not exists public.travel_stories (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  location text not null,
  visit_date date not null,
  content text not null,
  photos jsonb default '[]'::jsonb,
  created_at timestamptz default now()
);

-- Index for chronological queries
create index if not exists idx_travel_stories_visit_date on public.travel_stories (visit_date desc);

-- 2. Enable Row Level Security (RLS)
alter table public.travel_stories enable row level security;

-- Drop existing policies if re-running
drop policy if exists "Public can view stories" on public.travel_stories;
drop policy if exists "Authenticated author can insert" on public.travel_stories;
drop policy if exists "Authenticated author can update" on public.travel_stories;
drop policy if exists "Authenticated author can delete" on public.travel_stories;

-- 3. Public Read Policy (Anyone in the world can read and view your travel stories)
create policy "Public can view stories"
  on public.travel_stories for select
  using (true);

-- 4. Author Write Policies (Only logged-in users with a valid Supabase auth JWT can write)
create policy "Authenticated author can insert"
  on public.travel_stories for insert
  with check (auth.role() = 'authenticated');

create policy "Authenticated author can update"
  on public.travel_stories for update
  using (auth.role() = 'authenticated');

create policy "Authenticated author can delete"
  on public.travel_stories for delete
  using (auth.role() = 'authenticated');

-- 5. Seed initial field journal stories (optional starter data)
insert into public.travel_stories (title, location, visit_date, content, photos)
values
  (
    'The Silent Geometry of Cold Deserts & Monasteries',
    'Spiti Valley, Himachal Pradesh',
    '2024-09-18',
    'Ascending through Kunzum Pass into Spiti Valley is a stark transition into another geological epoch. The bare mountain scree reveals millions of years of marine sedimentary folds from the ancient Tethys Sea.

Spent mornings listening to ritual chants at Key Monastery, where 1,000-year-old mud-brick structures hang suspended above the turquoise Spiti River braided over glacial gravels.',
    '[
      {
        "url": "https://images.unsplash.com/photo-1581793745862-99fde7fa73d2?auto=format&fit=crop&w=1200&q=80",
        "caption": "Wind-sculpted sedimentary peaks rising over the Spiti River basin at dawn."
      },
      {
        "url": "https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80",
        "caption": "Key Monastery perched high on the barren hill terrace."
      }
    ]'::jsonb
  ),
  (
    'Bamboo Groves, Moss Gardens, and Solitary Kyoto Paths',
    'Kyoto & Uji, Japan',
    '2023-11-04',
    'In autumn, Kyoto shifts toward subtle ochres and vermilions. Early walks through the Sagano bamboo paths before daylight reveal how acoustics shape architecture in traditional Japanese sanctuaries.

In Uji, traditional green tea roasting aromas fill the cobblestones alongside ancient river locks that have controlled mountain runoff for seven centuries.',
    '[
      {
        "url": "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=1200&q=80",
        "caption": "Late afternoon light filtering through the stone lanterns of Higashiyama."
      },
      {
        "url": "https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80",
        "caption": "Reflections in the temple ponds amidst early maple autumn foliage."
      },
      {
        "url": "https://images.unsplash.com/photo-1528164344705-475426879c0d?auto=format&fit=crop&w=800&q=80",
        "caption": "Morning mist rising over the Katsura River bridge."
      }
    ]'::jsonb
  ),
  (
    'Monsoon Mist & Endemic Canopy in the Shola Forests',
    'Western Ghats, Karnataka',
    '2022-07-22',
    'The Southwestern Monsoon arrives with immense hydrologic force. The montane evergreen forests (Sholas) act as giant sponges, trapping precipitation and discharging clean water that feeds southern India''s river systems.

Observed bioluminescent fungi glowing in decayed tree barks at midnight during continuous drizzle.',
    '[
      {
        "url": "https://images.unsplash.com/photo-1511497584788-87676104235f?auto=format&fit=crop&w=1200&q=80",
        "caption": "Cloud layer rolling over the endemic montane shola-grassland mosaic."
      }
    ]'::jsonb
  )
on conflict do nothing;

