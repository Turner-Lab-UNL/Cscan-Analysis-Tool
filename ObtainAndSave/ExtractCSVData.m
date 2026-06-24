function ExtractCSVData(FileName,ScanSettings,Waves,Computer)

fid = fopen(FileName); % File name

if Computer ==1 || Computer==2
    DataStart=false;
    i=1;
    while DataStart==false
        text{i} = fgetl(fid);
        if ~isempty(text{i})
            DataStart=isstrprop(text{i}(1),'digit');
        end
        i=i+1;
    end
    StartCell=i-1;
    fclose(fid);
    Names=cell(1,7);
    if Computer==1
        Names={'A/D Delay(us):',' A/D Width(us):','Scanning Length:',...
            'Scanning Resolution:','Index Length:','Index Resolution:','A/D Rate(MHz):'};
        FirstDataLine=3; % Data starts in third column. Needed for matrix rearranging
    else
        
        fid = fopen('UtWin_Naming_File.txt');
        k=1;
        NameText{k}=fgetl(fid);
        while ischar(NameText{k})
            k=k+1;
            NameText{k} = fgetl(fid);            
        end
        NameText{k}='end';
        fclose(fid);
        % Find rows corresponding to names
    Rows(1)=find(contains(NameText,'Scanning Length:'));
    Rows(2)=find(contains(NameText,'Scanning Resolution:'));
    Rows(3)=find(contains(NameText,'Index Length'));
    Rows(4)=find(contains(NameText,'Indexing Resolution:'));
    Rows(5)=find(contains(NameText,'Window Delay:'));
    Rows(6)=find(contains(NameText,'Window Width:'));
    Rows(7)=find(contains(NameText,'Sampling Frequency:'));
    Rows(8)=find(contains(NameText,'First Data:'));

    % Find correct names in rows
        for m=1:7
        Spaces=double(isspace(NameText{Rows(m)}));
        Spaces1=find(Spaces==1);        
        Names{m}=strtrim(NameText{Rows(m)}(Spaces1(2):end));      
        end
        Spaces=double(isspace(NameText{Rows(8)}));
        Spaces1=find(Spaces==1);        
        FirstDataLine=str2double(strtrim(NameText{Rows(8)}(Spaces1(2):end)));
    end
    
    
    DelayCell=find(contains(text,Names{1}));
    WidthCell=find(contains(text,Names{2}));
    ScanLengthCell=find(contains(text,Names{3}));
    ScanResCell=find(contains(text,Names{4}));
    IndexLengthCell=find(contains(text,Names{5}));
    IndexResCell=find(contains(text,Names{6}));
    SamplingCell=find(contains(text,Names{7}));

    Check=DelayCell + WidthCell + ScanLengthCell + ScanResCell + IndexLengthCell + IndexResCell + SamplingCell+StartCell;
    if isempty(Check)
        f=gcf;
        f.Children(1)
        error('Scan Settings were not entered correctly. Operation terminated')

    end
    
    csv_loc=[DelayCell WidthCell ScanLengthCell,ScanResCell,IndexLengthCell,IndexResCell,SamplingCell,StartCell];
 
    
    NumStart=zeros(1,7);
    for j=1:7
            temp=isstrprop(text{csv_loc(j)},'digit');
            temp1=find(temp==true);
            if isempty(temp1)
                error('ScanSettings were not entered correctly. Operation termionated')
            end
            NumStart(j)=temp1(1);  
    end
    
elseif Computer==3 %% Paul Panneta's stuff
    
    for i=1:11 
        t{i} = fgetl(fid);
    end
    
    temp1= regexprep(t{2}, '\t', '_');
    separation=strfind(temp1,'_');
    time_len=str2double(temp1(1:separation(1)-1));
    scan_num=str2double(temp1(separation(1)+1:separation(2)-1));
    index_num=str2double(temp1(separation(2)+1:end));
    
    
    
    temp2= regexprep(t{4}, '\t', '_');
    separation=strfind(temp2,'_');
    w_s=str2double(temp2(1:separation(1)-1));
    w_e=str2double(temp2(separation(1)+1:separation(2)-1));
    w_w=w_e-w_s;
%     f_s=(w_e-w_s)/time_len;
    f_s=time_len/(w_e-w_s);
    text{1}=num2str(w_s);
    text{2}=num2str(w_w);
    text{7}=num2str(f_s);
    
    temp3= regexprep(t{6}, '\t', '_');
    separation=strfind(temp3,'_');
    scan_start=str2double(temp3(1:separation(1)-1));
    scan_end=str2double(temp3(separation(1)+1:separation(2)-1));
    scan_len=scan_end-scan_start;
    scan_res=scan_len/scan_num;
    text{3}=num2str(scan_len);
    text{4}=num2str(scan_res);

    temp4= regexprep(t{8}, '\t', '_');
    separation=strfind(temp4,'_');
    index_start=str2double(temp4(1:separation(1)-1));
    index_end=str2double(temp4(separation(1)+1:separation(2)-1));
    index_len=index_end-index_start;
    index_res=index_len/index_num;
    text{5}=num2str(index_len);
    text{6}=num2str(index_res);
    
    csv_loc=1:7; 
    csv_loc(8)=12;

    NumStart=zeros(1,7);
    for j=1:7
            temp=isstrprop(text{csv_loc(j)},'digit');
            temp1=find(temp==true);
            if isempty(temp1)
                error('ScanSettings were not entered correctly. Operation termionated')
            end
            NumStart(j)=temp1(1);  
    end
    FirstDataLine=1;
    
else    
        
        
end


ScanSettings.w_s =   str2double(text{csv_loc(1)}(NumStart(1):end));                %Window Start
ScanSettings.w_w =   str2double(text{csv_loc(2)}(NumStart(2):end));                %Window Width
ScanSettings.scan_len = str2double(text{csv_loc(3)}(NumStart(3):end));             %Length of scan in scannng direction
ScanSettings.scan_res = str2double(text{csv_loc(4)}(NumStart(4):end));             %Resolution of scan in scanning direction
ScanSettings.index_len = str2double(text{csv_loc(5)}(NumStart(5):end));            %Length of scan in index direction
ScanSettings.index_res = str2double(text{csv_loc(6)}(NumStart(6):end));            %Resolution of scan in index direction
ScanSettings.f_s =   str2double(text{csv_loc(7)}(NumStart(7):end));               	%Sampling Frequency
IndexPer(ScanSettings);
NumberOfWaveforms(ScanSettings)
scan_len_calc=ScanSettings.scan_res*ScanSettings.IndexPerRow;
index_len_calc=ScanSettings.index_res*ScanSettings.IndexPerColumn;
ScanSettings.scan_len=scan_len_calc;
ScanSettings.index_len=index_len_calc;


if ~isempty(Waves.waveform_matrix)
    clear Waves.waveform_matrix Waves.shifted_matrix Waves.shifted_vector 
end

% Reading the file 
fid = fopen(FileName); 
wf_mat = textscan(fid,'%f','HeaderLines',csv_loc(8)-1,'Delimiter',',');
Waves.waveform_matrix=wf_mat{1};
clear wf_mat;
Waves.waveform_matrix=reshape(Waves.waveform_matrix,[],ScanSettings.num_wfs)';   % Reshape Matrix 
Waves.waveform_matrix= Waves.waveform_matrix(:,FirstDataLine:end);              % This is the main matrix with all the data

if max(max(Waves.waveform_matrix))>1
    Waves.waveform_matrix=Waves.waveform_matrix/100;
end
[~,DataLength]=size(Waves.waveform_matrix);
time(ScanSettings,DataLength)
NumberOfWaveforms(ScanSettings)
fclose(fid);
end