function vect = SortUniqueTableVect(rs_table,rowname)
vect = sort(unique(rs_table{:,rowname}));
end