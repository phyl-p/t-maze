function pat_learned = ResultCodeToPatternsLearned(result_code,n_pat)

result_label = FailureModeDictionary(result_code);
label_code = FailureModeDictionary(result_label);
decimal_code = label_code-result_code;

switch result_label
    case {'activity died out','attractor','context attractor'}
        pat_learned = floor(decimal_code*1e3);
    case {'success'}
        pat_learned = n_pat;
    otherwise
        pat_learned = 0;
end
    