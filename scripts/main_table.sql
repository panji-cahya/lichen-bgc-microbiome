SELECT
	bgc.id as bgc_id,
	gcf_membership.gcf_id,
	dataset.name as barcode,
	bgc.orig_folder as sample,
	bgc.orig_filename as filename,
	gcf_membership.membership_value,
	bgc.on_contig_edge,
	chem_class.name as chem_class,
	chem_subclass.name as chem_subclass,
	chem_subclass_map.class_source as class_source,
	chem_subclass_map.type_source as type_source,
	MAX( IIF(taxon.level='0', taxon.name, NULL)) 'Kingdom',
	MAX( IIF(taxon.level='1', taxon.name, NULL)) 'Phylum',	
	MAX( IIF(taxon.level='2', taxon.name, NULL)) 'Class',
	MAX( IIF(taxon.level='3', taxon.name, NULL)) 'Order',
	MAX( IIF(taxon.level='4', taxon.name, NULL)) 'Family',
	MAX( IIF(taxon.level='5', taxon.name, NULL)) 'Genus',
	MAX( IIF(taxon.level='6', taxon.name, NULL)) 'Species'
FROM taxon, bgc
INNER JOIN bgc_taxonomy ON bgc_taxonomy.bgc_id==bgc.id
INNER JOIN taxon AS taxon_table on taxon.id==taxon_id
INNER JOIN gcf_membership ON gcf_membership.bgc_id==bgc.id
INNER JOIN bgc_class ON bgc_class.bgc_id==bgc.id
INNER JOIN chem_subclass ON chem_subclass.id==chem_subclass_id
INNER JOIN chem_class ON chem_class.id==chem_subclass.class_id
LEFT JOIN chem_subclass_map ON chem_subclass_map.subclass_id==chem_subclass.id
INNER JOIN dataset ON dataset.id==dataset_id
GROUP BY bgc.id