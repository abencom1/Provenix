select
    p.name          as product_name,
    b.name          as brand_name,
    ma.confidence,
    ma.source_type,
    f.name          as facility_name,
    f.fei_number,
    ma.is_current
from products p
join brands b on b.id = p.brand_id
left join manufacturer_attributions ma on ma.product_id = p.id and ma.is_current
left join facilities f on f.id = ma.facility_id
where p.is_seed_sku
order by p.name;
