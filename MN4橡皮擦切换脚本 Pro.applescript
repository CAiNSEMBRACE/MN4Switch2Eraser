-- ��ȡӦ�ó�������λ��
set appPath to POSIX path of (path to me)
set appResourcesPath to appPath & "Contents/Resources/"

-- ����洢�ļ�·��
set plistFilePath to appResourcesPath & "MarginNote4EraserProConfig.plist"

-- ����Ĭ��ֵ
set defaultIndexOfEraser to 4

-- ��������ȡ�����ļ�
on readPlistConfig(filePath)
	try
		tell application "System Events"
			set plistData to property list file filePath
			set eraserIndex to value of property list item "indexOfEraser" of plistData
			return eraserIndex as integer
		end tell
	on error errMsg
		display dialog "��ȡ�����ļ�ʱ����" & errMsg
		return ""
	end try
end readPlistConfig

-- ����: ���MN4�Ƿ�����Ļ����
on setMN4Front()
	try
		tell application "System Events"
			if not frontmost of process "MarginNote 4" then
				set frontmost of process "MarginNote 4" to true
			end if
		end tell
	on error errMsg
		display dialog "MarginNote 4 �����ö�ʧ��: " & errMag
	end try
end setMN4Front

-- ��������ļ��Ƿ���ڲ���ȡ����
set indexOfEraser to ""
try
	set indexOfEraser to readPlistConfig(plistFilePath)
	if indexOfEraser is "" then error "�����ļ�Ϊ��"
on error errMsg
	-- �����ļ������ڻ���Ч����ʾ�û�����
	display dialog "�����ļ���ȡʧ�ܣ�" & errMsg
	set userInput to display dialog "��������Ƥ����ť����ţ���1��ʼ����" default answer (defaultIndexOfEraser as string)
	set indexOfEraser to text returned of userInput as integer
	-- ���û������ֵ�洢�������ļ�
	set configContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>indexOfEraser</key>
	<integer>" & indexOfEraser & "</integer>
</dict>
</plist>"
	try
		do shell script "echo " & quoted form of configContent & " > " & quoted form of plistFilePath
	on error writeErrMsg
		display dialog "�޷�д�������ļ���" & writeErrMsg
	end try
end try

-- ȷ�� indexOfEraser ������
set indexOfEraser to indexOfEraser as integer

setMN4Front()
tell application "System Events"
	tell process "MarginNote 4"
		-- ��ȡMN4���д���
		set windowList to windows
		
		if (count of windowList) is 0 then
			display dialog "û��������,�ǲ����������С����."
		else
			-- ������ڴ��ڣ���ȡ���һ������
			set targetWindow to item (count of windows) of windows
			
			-- ���Բ�����Ļ�Ϸ�������
			try
				set buttonList to buttons of scroll area 1 of group 3 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
			on error
				try
					set buttonList to buttons of scroll area 1 of group 4 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
				on error
					try
						set buttonList to buttons of scroll area 1 of group 6 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
					on error errMsg
						display dialog "�������Ҳ�����,�㻹����Щʲô,��UI�Ѿ�����,��ͱ���������ĥ" & errMsg
					end try
				end try
			end try
			
			-- �ҵ���Ƥ��ť���Ҵ�������¼�
			set countOfButtons to count of buttonList
			if countOfButtons is 0 then
				display dialog "�⹤�����ǿյ�?"
			else
				-- ����ʹ�������ļ��е�ֵ
				set buttonOfEraser to missing value
				try
					set buttonOfEraser to item indexOfEraser of buttonList
				on error
					-- �����ļ��е�ֵ��Ч��ʹ��Ĭ��ֵ
					try
						set buttonOfEraser to item defaultIndexOfEraser of buttonList
					on error
						display dialog "��Ҳû�ҵ���Ƥ����ť,���������ļ���Ĭ��ֵ��" & plistFilePath
					end try
				end try
				
				if buttonOfEraser is not missing value then
					set eraserSelected to selected of buttonOfEraser
					if eraserSelected then
						--��Ƥ���Ѿ�ѡ��,���л��ص�һ����
						set buttonOfFirstPen to item 1 of buttonList
						try
							click buttonOfFirstPen
						on error
							display dialog "�л�ʧ��,����Ƶ�����!"
						end try
					else
						try
							click buttonOfEraser
						on error
							display dialog "�л�ʧ��,����Ƶ�����!"
						end try
					end if
				end if
			end if
		end if
	end tell
end tell