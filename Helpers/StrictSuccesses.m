function pld_strict=StrictSuccesses(f)
npat_space = f.npat_space;
pld=f.pat_learned_data;

pld_strict = zeros(size(pld));

for i = 1:size(pld,3)
    npat=npat_space(i);
    pld_strict(:,:,i)=pld(:,:,i)>=npat;
end