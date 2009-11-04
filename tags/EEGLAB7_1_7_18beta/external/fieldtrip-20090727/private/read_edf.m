function [dat] = read_edf(filename, hdr, begsample, endsample, chanindx);

% READ_EDF reads specified samples from an EDF continous datafile
% It neglects all trial boundaries as if the data was acquired in
% non-continous mode.
%
% Use as
%   [hdr] = read_edf(filename);
% where
%    filename        name of the datafile, including the .bdf extension
% This returns a header structure with the following elements
%   hdr.Fs           sampling frequency
%   hdr.nChans       number of channels
%   hdr.nSamples     number of samples per trial
%   hdr.nSamplesPre  number of pre-trigger samples in each trial
%   hdr.nTrials      number of trials
%   hdr.label        cell-array with labels of each channel
%   hdr.orig         detailled EDF header information
%
% Or use as
%   [dat] = read_edf(filename, hdr, begsample, endsample, chanindx);
% where
%    filename        name of the datafile, including the .bdf extension
%    hdr             header structure, see above
%    begsample       index of the first sample to read
%    endsample       index of the last sample to read
%    chanindx	     index of channels to read (optional, default is all)
% This returns a Nchans X Nsamples data matrix

% Copyright (C) 2006, Robert Oostenveld
%
% $Log: not supported by cvs2svn $
% Revision 1.1  2009/01/14 09:24:45  roboos
% moved even more files from fileio to fileio/privtae, see previous log entry
%
% Revision 1.2  2008/09/30 07:47:04  roboos
% replaced all occurences of setstr() with char(), because setstr is deprecated by Matlab
%
% Revision 1.1  2006/02/01 08:18:48  roboos
% new implementation, based on some EEGLAB code and a mex file for the binary part of the data
%

if nargin==1
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % read the header, this code is from EEGLAB's openbdf
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  FILENAME = filename;

  % defines Seperator for Subdirectories
  SLASH='/';
  BSLASH=char(92);

  cname=computer;
  if cname(1:2)=='PC' SLASH=BSLASH; end;

  fid=fopen(FILENAME,'r','ieee-le');
  if fid<0
    fprintf(2,['Error LOADEDF: File ' FILENAME ' not found\n']);
    return;
  end;

  EDF.FILE.FID=fid;
  EDF.FILE.OPEN = 1;
  EDF.FileName = FILENAME;

  PPos=min([max(find(FILENAME=='.')) length(FILENAME)+1]);
  SPos=max([0 find((FILENAME=='/') | (FILENAME==BSLASH))]);
  EDF.FILE.Ext = FILENAME(PPos+1:length(FILENAME));
  EDF.FILE.Name = FILENAME(SPos+1:PPos-1);
  if SPos==0
    EDF.FILE.Path = pwd;
  else
    EDF.FILE.Path = FILENAME(1:SPos-1);
  end;
  EDF.FileName = [EDF.FILE.Path SLASH EDF.FILE.Name '.' EDF.FILE.Ext];

  H1=char(fread(EDF.FILE.FID,256,'char')');     %
  EDF.VERSION=H1(1:8);                          % 8 Byte  Versionsnummer
  %if 0 fprintf(2,'LOADEDF: WARNING  Version EDF Format %i',ver); end;
  EDF.PID = deblank(H1(9:88));                  % 80 Byte local patient identification
  EDF.RID = deblank(H1(89:168));                % 80 Byte local recording identification
  %EDF.H.StartDate = H1(169:176);               % 8 Byte
  %EDF.H.StartTime = H1(177:184);               % 8 Byte
  EDF.T0=[str2num(H1(168+[7 8])) str2num(H1(168+[4 5])) str2num(H1(168+[1 2])) str2num(H1(168+[9 10])) str2num(H1(168+[12 13])) str2num(H1(168+[15 16])) ];

  % Y2K compatibility until year 2090
  if EDF.VERSION(1)=='0'
    if EDF.T0(1) < 91
      EDF.T0(1)=2000+EDF.T0(1);
    else
      EDF.T0(1)=1900+EDF.T0(1);
    end;
  else ;
    % in a future version, this is hopefully not needed
  end;

  EDF.HeadLen = str2num(H1(185:192));  % 8 Byte  Length of Header
  % reserved = H1(193:236);	           % 44 Byte
  EDF.NRec = str2num(H1(237:244));     % 8 Byte  # of data records
  EDF.Dur = str2num(H1(245:252));      % 8 Byte  # duration of data record in sec
  EDF.NS = str2num(H1(253:256));       % 8 Byte  # of signals

  EDF.Label = char(fread(EDF.FILE.FID,[16,EDF.NS],'char')');
  EDF.Transducer = char(fread(EDF.FILE.FID,[80,EDF.NS],'char')');
  EDF.PhysDim = char(fread(EDF.FILE.FID,[8,EDF.NS],'char')');

  EDF.PhysMin= str2num(char(fread(EDF.FILE.FID,[8,EDF.NS],'char')'));
  EDF.PhysMax= str2num(char(fread(EDF.FILE.FID,[8,EDF.NS],'char')'));
  EDF.DigMin = str2num(char(fread(EDF.FILE.FID,[8,EDF.NS],'char')'));
  EDF.DigMax = str2num(char(fread(EDF.FILE.FID,[8,EDF.NS],'char')'));

  % check validity of DigMin and DigMax
  if (length(EDF.DigMin) ~= EDF.NS)
    fprintf(2,'Warning OPENEDF: Failing Digital Minimum\n');
    EDF.DigMin = -(2^15)*ones(EDF.NS,1);
  end
  if (length(EDF.DigMax) ~= EDF.NS)
    fprintf(2,'Warning OPENEDF: Failing Digital Maximum\n');
    EDF.DigMax = (2^15-1)*ones(EDF.NS,1);
  end
  if (any(EDF.DigMin >= EDF.DigMax))
    fprintf(2,'Warning OPENEDF: Digital Minimum larger than Maximum\n');
  end
  % check validity of PhysMin and PhysMax
  if (length(EDF.PhysMin) ~= EDF.NS)
    fprintf(2,'Warning OPENEDF: Failing Physical Minimum\n');
    EDF.PhysMin = EDF.DigMin;
  end
  if (length(EDF.PhysMax) ~= EDF.NS)
    fprintf(2,'Warning OPENEDF: Failing Physical Maximum\n');
    EDF.PhysMax = EDF.DigMax;
  end
  if (any(EDF.PhysMin >= EDF.PhysMax))
    fprintf(2,'Warning OPENEDF: Physical Minimum larger than Maximum\n');
    EDF.PhysMin = EDF.DigMin;
    EDF.PhysMax = EDF.DigMax;
  end
  EDF.PreFilt= char(fread(EDF.FILE.FID,[80,EDF.NS],'char')');	%
  tmp = fread(EDF.FILE.FID,[8,EDF.NS],'char')';	%	samples per data record
  EDF.SPR = str2num(char(tmp));               %	samples per data record

  fseek(EDF.FILE.FID,32*EDF.NS,0);

  EDF.Cal = (EDF.PhysMax-EDF.PhysMin)./(EDF.DigMax-EDF.DigMin);
  EDF.Off = EDF.PhysMin - EDF.Cal .* EDF.DigMin;
  tmp = find(EDF.Cal < 0);
  EDF.Cal(tmp) = ones(size(tmp));
  EDF.Off(tmp) = zeros(size(tmp));

  EDF.Calib=[EDF.Off';(diag(EDF.Cal))];
  %EDF.Calib=sparse(diag([1; EDF.Cal]));
  %EDF.Calib(1,2:EDF.NS+1)=EDF.Off';

  EDF.SampleRate = EDF.SPR / EDF.Dur;

  EDF.FILE.POS = ftell(EDF.FILE.FID);
  if EDF.NRec == -1                            % unknown record size, determine correct NRec
    fseek(EDF.FILE.FID, 0, 'eof');
    endpos = ftell(EDF.FILE.FID);
    EDF.NRec = floor((endpos - EDF.FILE.POS) / (sum(EDF.SPR) * 2));
    fseek(EDF.FILE.FID, EDF.FILE.POS, 'bof');
    H1(237:244)=sprintf('%-8i',EDF.NRec);      % write number of records
  end;

  EDF.Chan_Select=(EDF.SPR==max(EDF.SPR));
  for k=1:EDF.NS
    if EDF.Chan_Select(k)
      EDF.ChanTyp(k)='N';
    else
      EDF.ChanTyp(k)=' ';
    end;
    if findstr(upper(EDF.Label(k,:)),'ECG')
      EDF.ChanTyp(k)='C';
    elseif findstr(upper(EDF.Label(k,:)),'EKG')
      EDF.ChanTyp(k)='C';
    elseif findstr(upper(EDF.Label(k,:)),'EEG')
      EDF.ChanTyp(k)='E';
    elseif findstr(upper(EDF.Label(k,:)),'EOG')
      EDF.ChanTyp(k)='O';
    elseif findstr(upper(EDF.Label(k,:)),'EMG')
      EDF.ChanTyp(k)='M';
    end;
  end;

  EDF.AS.spb = sum(EDF.SPR);	% Samples per Block
  bi=[0;cumsum(EDF.SPR)];

  idx=[];idx2=[];
  for k=1:EDF.NS,
    idx2=[idx2, (k-1)*max(EDF.SPR)+(1:EDF.SPR(k))];
  end;
  maxspr=max(EDF.SPR);
  idx3=zeros(EDF.NS*maxspr,1);
  for k=1:EDF.NS, idx3(maxspr*(k-1)+(1:maxspr))=bi(k)+ceil((1:maxspr)'/maxspr*EDF.SPR(k));end;

  %EDF.AS.bi=bi;
  EDF.AS.IDX2=idx2;
  %EDF.AS.IDX3=idx3;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % convert the header to Fieldtrip-style
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if any(EDF.SampleRate~=EDF.SampleRate(1))
    error('channels with different sampling rate not supported');
  end
  hdr.Fs          = EDF.SampleRate(1);
  hdr.nChans      = EDF.NS;
  hdr.label       = cellstr(EDF.Label);
  % it is continuous data, therefore append all records in one trial
  hdr.nSamples    = EDF.Dur * EDF.SampleRate(1);
  hdr.nSamplesPre = 0;
  hdr.nTrials     = EDF.NRec;
  hdr.orig        = EDF;

  % return the header
  dat = hdr;

else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % read the data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin<5
    chanindx = 1:hdr.nChans;
  end

  % determine the trial containing the begin and end sample
  epochlength = hdr.nSamples;
  begepoch    = floor((begsample-1)/epochlength) + 1;
  endepoch    = floor((endsample-1)/epochlength) + 1;
  nepochs     = endepoch - begepoch + 1;
  dat         = zeros(length(chanindx),nepochs*epochlength);

  % read and concatenate all required data epochs
  for i=begepoch:endepoch
    % FIXME: this can be implemented more efficient if only one channel has to be read
    offset = hdr.orig.HeadLen + (i-1)*hdr.nSamples*hdr.nChans*3;
    % NOTE: this is the only difference between the bdf and edf implementation
    % buf  = read_24bit(filename, offset, hdr.nSamples*hdr.nChans);
    buf    = read_16bit(filename, offset, hdr.nSamples*hdr.nChans);
    buf    = reshape(buf, hdr.nSamples, hdr.nChans);
    dat(:,((i-begepoch)*epochlength+1):((i-begepoch+1)*epochlength)) = buf(:,chanindx)';
  end

  % select the desired samples
  begsample = begsample - (begepoch-1)*epochlength;  % correct for the number of bytes that were skipped
  endsample = endsample - (begepoch-1)*epochlength;  % correct for the number of bytes that were skipped
  dat = dat(:, begsample:endsample);

  % FIXME: calibrate the data
end
