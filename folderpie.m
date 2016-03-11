function folderpie(folder, opt)
%FOLDERPIE Create layered pie chart of folder sizes
%
% folderpie(folder, opt)
%
% Input variables:
%
%   folder: full or relative path
%
%   opt:    string of options to be passed to du command



if nargin == 2
    [s,r] = system(sprintf('du %s %s', opt, folder));
else
    [s,r] = system(sprintf('du %s', folder));
end

r = regexprep(r, 'du[^\n]*\n', ''); % Remove any du error messages (like Permission denied)

data = textscan(r, '%f %[^\n]'); 
sz = data{1};
subfolder = data{2};

parent = subfolder{end};
% subfolder = regexprep(subfolder(1:end-1), parent, '');
% sz = sz(1:end-1);

label = cellfun(@(x) regexp(x, filesep, 'split'), subfolder, 'uni', 0);

nsub = length(label);

% Change so size only reflects non-subfoldered contents

sz2 = sz;

nlev = cellfun(@length, label);
for ilev = 1:max(nlev)
    for ii = 1:nsub
        if nlev(ii) == ilev
            thisfolder = label{ii}{ilev};
            ischild = false(nsub,1);
            for jj = 1:nsub
                if nlev(jj) == ilev+1 && isequal(label{ii}(1:ilev), label{jj}(1:ilev))  %strcmp(label{jj}{ilev}, thisfolder)
                   ischild(jj) = true;
                end
            end
            childsz = sum(sz(ischild));
            sz2(ii) = sz(ii) - childsz;
%             if sz2(ii) < 0
%                 blah
%             end
        end
    end
end


h = pielayered(sz2, label);
set(h.t, 'fontsize', 8, 'interpreter', 'none');


sztot = sum(sz2) ./ [1; 2; 2*1024; 2*1024*1024];
suffix = {'B', 'KB', 'MB', 'GB'};
idx = find(sztot > 1, 1, 'last');
sztotstr = sprintf('%.2f %s', sztot(idx), suffix{idx});
textLoc(sztotstr, 'northwest');



