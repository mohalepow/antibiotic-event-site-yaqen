-- Enforce one community comic panel per participant owner token.
-- Run this once in Supabase SQL Editor.
-- Existing duplicate owner tokens are reported first; resolve them before creating the index.
DO $$
DECLARE
  duplicate_tokens integer;
BEGIN
  SELECT COUNT(*) INTO duplicate_tokens
  FROM (
    SELECT owner_token
    FROM public.community_artworks
    WHERE owner_token IS NOT NULL AND owner_token <> ''
    GROUP BY owner_token
    HAVING COUNT(*) > 1
  ) duplicates;

  IF duplicate_tokens > 0 THEN
    RAISE EXCEPTION 'Cannot enforce one panel per participant yet: % owner token(s) already own multiple panels. Review duplicate owner_token values in community_artworks first.', duplicate_tokens;
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS community_artworks_one_panel_per_owner
ON public.community_artworks (owner_token)
WHERE owner_token IS NOT NULL AND owner_token <> '';
