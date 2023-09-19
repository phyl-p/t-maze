function my_struct = WriteToStruct(my_struct,varargin)
n_name_value_args = length(varargin);
if logical(mod(n_name_value_args,2)) %if name-values cannot be paired, i.e. if varargin has odd arguments
    error('please use name value pair arguments')
end

n_nvpairs = n_name_value_args/2;
for j = 1:n_nvpairs
    field = varargin{    2*j-1    };
    if ~ischar(field)
        error(['argument ', num2str(2*j) ' must be a character vector.'])
    end
    value = varargin{    2*j      };
    my_struct.(field) = value;
end
















