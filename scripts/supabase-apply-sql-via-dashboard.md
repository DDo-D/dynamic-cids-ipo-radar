# Supabase SQL Editor로 스키마 적용 (CLI IPv6 실패 시)

1. https://supabase.com/dashboard/project/qghquidouqdrjxdjyrgy/sql/new
2. 아래 파일 내용을 **순서대로** 붙여넣고 Run:
   - `supabase/migrations/20260302064116_init_ipo_radar_schema.sql`
   - `supabase/migrations/20260302173000_add_listing_date.sql`
3. Table Editor에서 `settings`, `ipo_items` 테이블이 보이면 완료
