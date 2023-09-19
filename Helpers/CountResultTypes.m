%rulename = 'Bid';

function count = CountResultTypes(rulename, query)
if class(query)=="char"
    result_code = FailureModeDictionary(query);
else
    result_code = query;
end

f = load(['OutputsSLURM/',rulename,'pat_learned_data.mat']);

result_classifications = round(f.result_data,-1);

count = mean(result_classifications(:)==result_code);


