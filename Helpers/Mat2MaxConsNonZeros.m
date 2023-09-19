function maxconVect=Mat2MaxConsNonZeros(mat)
%counts for each column the maximum number of consecutive nonzero entries
counter=zeros(1,size(mat,2));
maxconVect=counter;
for i = 1:size(mat,1)
    row_bool=mat(i,:)>0;
    counter=counter.*row_bool+row_bool;
    maxconVect=max(counter,maxconVect);
end
