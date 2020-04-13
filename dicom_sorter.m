function[output] = dicom_sorter(root_dir, output_dir)
% sorts dicom-files based on protocol name, from Phillips 3T scanner
% Input:
%       root_dir = Directory containing one folder for each subject, which
%       in turn contains the dicoms for this subject.
%
%       output_dir = Directory where the copied/ output files will be
%       stored; for each participant a folder will be created; in each
%       participant folder multiple folders will be created for each
%       protocol.
%       IMPORTANT!!!!: Do not put the output_dir into the root_dir!!!!
% Output:
%       One variable/struct per subject containing Protocol names and
%       number of images associated with that protocol. Will be saved in
%       the current directory.
%
% Main code from Audun, UiO;
% Change and fixes Ren? Skukies, UiO, 01.2020

% % For testing...
% root_dir = 'C:\Users\ReneS\Desktop\MRI\dicom_messy\';
% output_dir = 'C:\Users\ReneS\Desktop\MRI\dicom_sorted\';

% Change these paths so the provided functions will be added
addpath('C:\Users\ReneS\OneDrive\HTDP\Dicom Sorter')
addpath('C:\Users\ReneS\OneDrive\HTDP\Dicom Sorter\dicm2nii')

% Initiliaze Progress bar
%     multi_progressbar(0,0)

%defining variables
a = 1;
new = 0;
subjects = struct('id', {});
sub_struct = dir(root_dir);
err_struct = struct('file', {});
prevProg = 0;
dict = dicm_dict('phillips', 'ProtocolName'); % Get 'dictionary' for the used scanner
InstDict = dicm_dict('phillips', 'InstanceNumber'); % Get 'dictionary' for the used scanner



%Getting list of subjects
for j = 3:length(sub_struct)
    if sub_struct(j).isdir == 1
        subjects(a).id = sub_struct(j).name;
        a = a+1;
    end
end

fprintf('\n\n---------- Folder summary ----------');
fprintf('\nFolders(subjects) in root-directory: ');
for i = 1:length(subjects)
    fprintf('\n\t%s', subjects(i).id);
end
fprintf('\n\n')
%     multiWaitbar( 'Total Progress', 0 );


multi_progressbar('Subjects', 'Files')
%g = waitbar(0,'Total progress');


%cycling through all subjects
for j = 1:length(subjects)
    
    prot_nums = 0;
    prot_nums = struct('protocolName', {}, 'protNum', {});
    
    % Update/ reset progress bar
    multi_progressbar(j/length(subjects), [])
    
    
    %recursive search for all DICOM-files startin with IM
    files = rdir(fullfile(root_dir, subjects(j).id)); % Finds all IM files
    
    disp('Sorting DICOMs...')
    for k = 1:length(files)
        
        % Update progress bar
        multi_progressbar([], k/length(files))
        if ~mod(k, 50)
            disp(strjoin(files(k)));  %.name
        end
        [s, ~] = dicm_hdr(strjoin(files(k)), dict);
        
        
        %prot = temp_info.ProtocolName;
        prot = s.ProtocolName;
        new = 0;
        %Keeping track of how many files put in each category
        for i = 1:length(prot_nums)
            if strcmp(prot, prot_nums(i).protocolName)
                prot_nums(i).protNum = prot_nums(i).protNum + 1;
                prot_nums(i).protNum;
                fileNum = prot_nums(i).protNum;
                
                new = 1;
            end
        end
        
        %If a new protocol is found make a new entry for it
        if new == 0
            
            prot_nums(length(prot_nums) + 1).protocolName = prot;
            prot_nums(length(prot_nums)).protNum = 1;
            
            fileNum = prot_nums(length(prot_nums)).protNum;
        end
        
        %make folder for new files if the folder for the protocol does
        %not exist
        
        if ~exist(fullfile(output_dir, subjects(j).id, prot), 'dir')
            mkdir(fullfile(output_dir, subjects(j).id, prot))
        end
        
        %copies DICOM-files to appropriate folder
        strjoin(files(k));
        fullfile(output_dir, prot, sprintf('IM_%d', fileNum));
        
        copyfile(strjoin(files(k)), fullfile(output_dir, subjects(j).id, prot, sprintf('IM_%d', fileNum)))
        
        save(strcat('prot_nums', '_', subjects(j).id), 'prot_nums')
        
        if k == prevProg+10
            totProg = (10/length(files))/length(subjects);
            prevProg = k;
        end
        %waitbar(k / length(files))
        if k == length(files)
            prevProg = 0;
        end
        
    end % End of File loop
end % End of Subject loop


output = prot_nums;

end