function DisplayStruct(my_struct)

%names = fieldnames( parameters );
%{
%this commented block removes all fields that start with toggle
subStr = 'toggle';
parameters_shown = ...
    rmfield(parameters,names(contains(names,subStr)));
%}
struct_str_vects= structfun(@string,my_struct,'UniformOutput',false);
struct_str      = structfun(@join,struct_str_vects);

displayValues(fieldnames(my_struct),cellstr(struct_str))


