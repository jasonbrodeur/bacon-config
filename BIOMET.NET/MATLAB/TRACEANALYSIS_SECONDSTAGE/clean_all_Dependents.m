function [traces_out,ind]= clean_all_dependents(trace_str,file_path,ct)
% This function cleans all the dependent traces for each trace in the array of 
% structures 'trace_str'. For all points cleaned in a single trace, each dependent
% trace will have the same points cleaned.  
%
%	INPUT:
%			'trace_str'		- An array of structure representing each trace listed in the 
%								initialization file.
%			'file_path'		- The location to retrieve the uncleaned trace data.
%			'ct'				-A count of the total number of dependents.  This is used
%								to create a matlab 'waitbar'.
%
%	OUTPUT:
%			'traces_out'	-Updated trace array
%			'ind'				-index of current trace being cleaned incase an error occurrs.
% 
% NOTES: See the function 'find_all_dependents' as well.
%

if ~exist('ct') | isempty(ct)
    ct = length(trace_str);
end

traces_out = [];

bgc = [0 0.36 0.532];
disp('Cleaning traces....');
h = waitbar(0,'Cleaning traces....');
set(h,'Color',bgc);
set(get(h,'Children'),'Color',bgc,'LineWidth',0.5);
set(get(get(h,'Children'),'Title'),'Color',[1 1 1])
h1 = get(get(h,'Children'),'Children');
set(h1(1),'Color',[1 1 1]);

count = 0;
for ind=1:length(trace_str)
   trace_var = trace_str(ind);   
   %check if this trace has dependent traces:
   if isfield(trace_var,'ind_depend') & ~isempty(trace_var.ind_depend)

      if ~isfield(trace_var,'data')
          %call the helper function (below) to load the data:
          trace_temp = get_trace_info(trace_var,file_path);	
      else
          trace_temp = trace_var;
      end

      if isempty(trace_temp)         
         str = ['While cleaning dependents could not find the data file: ' trace_var.variableName '!'];
         disp(str);
      else 
         trace_var = trace_temp;
         %clean the trace containing the list of dependents(do not need to interpolate):
         % kai* Nov 21, 2001
         % made no_intep the default
         trace_var = clean_traces(trace_var);
         % end kai*
         %get all points that are removed:
         depend_pts = trace_var.stats.clean_flags;
         
         %For each dependent trace, update the points cleaned in the root trace:
         for dep = trace_var.ind_depend
            count = count + 1;
            trc = trace_str(dep);
            if ~isfield(trc,'stats') | ~isfield(trc.stats,'index')...
                  | ~isfield(trc.stats.index,'PtsDependClean')
               trc.stats.index.PtsDependClean =[];           
            end  
            if ishandle(h)
               waitbar(count/ct);         
            end         
            trace_str(dep).stats.index.PtsDependClean = ta_set_ind(trc.stats.index.PtsDependClean, depend_pts,'union');
            trace_str(dep).stats.numpts.dependCleaned = length(trace_str(dep).stats.index.PtsDependClean);
         end        
      end
   end   
end
if ishandle(h)
   close(h);
end

traces_out = trace_str;

%---------------------------------------------------------------------------
function data_out = get_trace_info(trace_var,file_path)
try
   if strcmp(file_path,'database')               
      %from the database:
      trace_var = ta_load_from_db(trace_var);
   else                
      % from a local input path containing binary files with names given by 
      % the traces 'variableName' field:
      % kai* 10 Nov, 2000
      % Before, this read
      % str = [file_path trace_var.variableName];
      % trace_var.data = trace_var.data_old;
      % str = [file_path 'DOY'];
      % trace_var.DOY = read_bor(str);
      % I put everyting into a function
      trace_var = ta_load_from_path(trace_var,file_path);   
   	% end kai*   
   end
catch
   data_out =[];
   return
end
data_out = trace_var;