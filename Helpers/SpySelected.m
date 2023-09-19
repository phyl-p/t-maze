function SpySelected(matrix,varargin)
%Function Syntax:
%(1) SpySelected(matrix,row_min,row_max,col_min,col_max)
%       is equivalent to spy(matrix(row_min:row_max,col_min:col_max)
%(2) SpySelected(matrix,row_min,row_max)
%       is a special case of (1)
%(3) SpySelected(matrix,[row_min,row_max],[col_min,col_max])
%(4) SpySelected(matrix,[row_min,row_max])
%       (3) and (4) are similar to (1) and (2).
%(5) SpySelected(matrix,logical_row_idx,logical_col_idx)
%       (idx stands for index)
%       is equivalent to spy(matrix(logical_row_idx,logical_col_idx))
%       Here, logical_row_idx and logical_col_idx are logical vectors, 
%       where row_idx must have the same length as the number of rows 
%       in matrix, and col_idx must have the same length as the number 
%       of cols.



%Function Specifications:
%check if varargin is a cell with all scalar or all vector entries, return
%error if there is an exception
%
%if all vectors, then use VectorToIndex() function to return the
%   first row, then column indices, whose formats depend on whether the 
%   vectors are logical
%if all scalars, then first two entries of varargin specify the inclusive
%   range of row indices, and the second two entries specify the inclusive
%   range of column indices.

%error check: we want to make sure varargin arguments are either all scalar
%or all vectors
n_scalar_args = 0;
for i = 1:length(varargin)
    n_scalar_args = n_scalar_args+isscalar(varargin{i});
end
%now we have the number of scalar arguments. If it is 0, we know that all
%arguments are vectors. If it is the same as the number of varargin
%arguments (i.e. length(varargin)) then all args are scalars. If it is some
%number in between, the function syntax was not correct so the function
%returns an error, specified in the 'otherwise' section of the switch block

switch n_scalar_args
    case 0
        %all varargin arguments are vectors. 
        %It is not yet known whether
        %the vector specified in varargin is a logical index or a vector of
        %length 2 that specifies a min and max index value, so we use the
        %VectorToIndex function to determine this.
        row_idx = VectorToIndex(varargin{1});
        %It is possible that the column indices were not specified in the
        %inputs of the function, so the same code as above, modified to
        %return the column indices, is placed in an if statement that
        %checks whether there are enough input arguments.
        if length(varargin) == 2
            col_idx = VectorToIndex(varargin{2});
        else
            %if there aren't enough input arguments, let the col_idx index
            %every column in the matrix.
            col_idx = 1:size(matrix,2);
        end
        %check for errors
        if islogical(row_idx)
            if length(row_idx)~=size(matrix,1) || length(col_idx)~=size(matrix,2)
                disp('the length of a logical index vector does not match the specified row or column size of the matrix')
            end
        end
    case length(varargin)
        %all varargin arguments are scalars
        row_min = varargin{1};
        row_max = varargin{2};
        row_idx = row_min:row_max;
        if row_max>size(matrix,1)
            error('row_max is too large')
        end
        %column indices might not have been specified, therefore use an if
        %statement similar to the one in the previous switch>case block
        if n_scalar_args == 4
            col_min = varargin{3};
            col_max = varargin{4};
            col_idx = col_min:col_max;
            if col_max>size(matrix,2)
                error('col_max is too large')
            end
        else
            col_idx = 1:size(matrix,2);
        end
        
    otherwise
        error('inputs after the 1st argument (i.e. the varargin arguments) must be either all scalars or all vectors')
end
try
    matrix_selection = matrix(row_idx,col_idx);
catch ME
    disp("param. neuron viewing range")
    if strcmp(ME.identifier,'MATLAB:badsubscript')
        error('Neuron viewing range must be less than or equal to the number of neurons')
    else
        rethrow(ME)
    end
end
spy(matrix_selection)
end





function idx = VectorToIndex(vector)

    if islogical(vector)
        idx = vector;
    elseif length(vector) == 2
        min = vector(1);
        max = vector(2);
        idx = min:max;
    else
        error('exception occurred; vector argument must be either logical or a range')
    end

end

