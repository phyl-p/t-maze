function answer = FailureModeDictionary(query)

switch class(query)
    case {'string','char'}
        key_col = 1;
        key = query;
    otherwise
        key_col = 2;
        key = round(query,-1); %if the query is a result_code, then round it to the nearest multiple of 10
end

%dictionary entries are listed in typical order of appearance 
%(i.e. from failure modes typical of initial network states 
%      to those typical of overtraining)
dictionary = ...
{
    'success'                   ,  10;
    'unknown failure mode'      ,   0;
    'noise'                     , -10;
    'activity died out'         , -20;
    'context attractor'         , -30;
    'attractor'                 , -40;
    'overcompression'           , -50;
};  

if key_col == 1     %if we are matching a character key to the dictionary
    dict_col = {dictionary{:,key_col}}';
else                %if we are matching a numeric code to the dict
    dict_col = [dictionary{:,key_col}]';
end

key_row = ismember(dict_col,key);

answer = dictionary{key_row,3-key_col};