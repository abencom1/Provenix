-- ============================================================================
-- PROVENIX — Manual certification verification results (2026-07-24)
--
-- Aaron manually checked all 5 claimed certifications at each certifier's
-- own site (per the worksheet's rule: NSF/USP/Informed-Choice require manual
-- lookup, never trust a brand's own marketing badge). All 5 confirmed found.
-- Updates status from 'claimed_unverified' -> 'active' and source from
-- 'dsld_label_claim' -> the manual-lookup source actually used.
--
-- Note on Kirkland: USP's tool lists the product as "50 mcg" rather than
-- "2000 IU" -- same amount, different unit convention (1 mcg vitamin D = 40
-- IU), confirmed as the same product.
-- ============================================================================

with p as (select id, name from products where is_seed_sku)
update certifications c
set status = 'active',
    source = v.source,
    cert_url = v.cert_url,
    last_verified = now()
from p, (values
    ('Nature Made Vitamin D3 2000 IU (50 mcg) Softgels — Item #2585', 'usp_verified', 'usp_manual_lookup', null),
    ('Ritual Essential for Women, Mint Essenced', 'usp_verified', 'usp_manual_lookup', null),
    ('Garden of Life Vitamin Code — Women (UPC 6 58010 11417 2)', 'other', 'nsf_manual_lookup', null),
    ('Optimum Nutrition Gold Standard 100% Whey, Double Rich Chocolate (UPC 7 48927 05226 8)', 'informed_choice', 'informed_choice_manual_lookup', null),
    ('Kirkland Signature Extra Strength Vitamin D3 2000 IU (UPC 0 96619 39391 6)', 'usp_verified', 'usp_manual_lookup',
     'https://www.quality-supplements.org/usp_verified_products?term%5B0%5D=brand%3AKirkland%20Signature&term%5B1%5D=supplement_type%3AVitamin')
) as v(product_name, cert_type, source, cert_url)
where c.product_id = p.id
  and p.name = v.product_name
  and c.cert_type = v.cert_type::certification_type;
