-- ��ȡӦ�ó�������λ��
set appPath to POSIX path of (path to me)
set appResourcesPath to appPath & "Contents/Resources/"

-- ����洢�ļ�·��
set plistFilePath to appResourcesPath & "MarginNote4EraserConfigMax.plist"

-- ����Ĭ��ֵ,ԭʼ�������Ƥ��λ�ڵ��ĸ�����λ��
set defaultIndexOfEraser to 4
set defaultIndexOfLastButton to 1

-- ��������ȡ�����ļ�������ע����
on readPlistConfig(filePath)
	try
		tell application "System Events"
			set plistData to property list file filePath
			set indexOfEraser to value of property list item "indexOfEraser" of plistData
			set indexOfLastButton to value of property list item "indexOfLastButton" of plistData
			return {indexOfEraser, indexOfLastButton}
		end tell
	on error errMsg
		display dialog "��ȡ�����ļ�ʱ����" & errMsg
		return {defaultIndexOfEraser, defaultIndexOfLastButton}
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
set configValues to ""
try
	set configValues to readPlistConfig(plistFilePath)
	if configValues is {defaultIndexOfEraser, defaultIndexOfLastButton} then error "�����ļ�Ϊ��"
on error errMsg
	-- �����ļ������ڻ���Ч����ʾ����
	display dialog "�����ļ���ȡʧ�ܣ�" & errMsg
	set userInput to display dialog "��������Ƥ����ť����ţ���1��ʼ����" default answer (defaultIndexOfEraser as string)
	set indexOfEraser to text returned of userInput as integer
	set indexOfLastButton to defaultIndexOfLastButton
	-- ���������Ƥ����ź���һ������Ĭ��ֵ�洢�������ļ�
	set configContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>indexOfEraser</key>
	<integer>" & indexOfEraser & "</integer>
	<key>indexOfLastButton</key>
	<integer>" & indexOfLastButton & "</integer>
</dict>
</plist>"
	try
		do shell script "echo " & quoted form of configContent & " > " & quoted form of plistFilePath
	on error writeErrMsg
		display dialog "�޷�д�������ļ���" & writeErrMsg
	end try
end try

-- �������ļ���ȡ��ֵ
set indexOfEraser to item 1 of configValues
set indexOfLastButton to item 2 of configValues
setMN4Front()
tell application "System Events"
	tell process "MarginNote 4"
		-- ���Ի�ȡ���д���
		set windowList to windows
		
		if (count of windowList) is 0 then
			--������ڲ�����,��֧����
			display dialog "δ�ҵ�������Ϣ,����MarginNote 4�ѱ�����."
		else
			-- ������ڴ��ڣ���ȡ���һ������
			set targetWindow to item (count of windows) of windows
			
			-- ���Բ�����Ļ�Ϸ�������
			try
				set buttonList to buttons of scroll area 1 of group 3 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
			on error
				-- ʧ�ܺ�����һ�����ܵ�·��
				try
					set buttonList to buttons of scroll area 1 of group 4 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
				on error
					-- �ٴγ���
					try
						set buttonList to buttons of scroll area 1 of group 6 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
					on error
						-- �޷�һһ�о�,��������
						display dialog "�������Ҳ�����,�㻹����Щʲô,��UI�Ѿ�����,��ͱ���������ĥ"
					end try
				end try
			end try
			
			-- �ҵ���Ƥ��ť���Ҵ�������¼�
			set countOfButtons to count of buttonList
			if countOfButtons is 0 then
				-- �����������������,���Ǳ����÷�֧
				display dialog "No buttons found of the MarginNote 4."
			else
				-- ����ʹ�������ļ��е�ֵ
				set buttonOfEraser to missing value
				try
					set buttonOfEraser to item indexOfEraser of buttonList
				on error
					-- �����ļ��е���Ƥ�����ֵ��Ч��ʹ��Ĭ��ֵ
					try
						set buttonOfEraser to item defaultIndexOfEraser of buttonList
					on error
						-- ��Ĭ��ֵҲ���ڴ���,��������֪
						display dialog "�޷��ҵ���Ƥ����ť�����������ļ���Ĭ��ֵ��"
					end try
				end try
				
				if buttonOfEraser is not missing value then
					set eraserSelected to selected of buttonOfEraser
					-- �жϰ�ťѡ�����
					if eraserSelected then
						-- �����Ƥ��ť�Ѿ���ѡ��,���޷���ȡ��һ����ť����Ϣ,��ʹ�������ļ��е�����
						set buttonOfLastSelected to item indexOfLastButton of buttonList
						try
							click buttonOfLastSelected
						on error errMsg
							display dialog "�л�ʧ��,����Ƶ�����! :" & errMsg
						end try
					else
						-- �����Ƥ��ťδѡ��
						-- ����ҳ���Ƥ�����ⱻѡ�еİ�ť����������ű��浽�����ļ�
						set lastSelectedButtonFound to false
						repeat with i from 1 to countOfButtons
							if i is not indexOfEraser then
								set buttonOfLastSelected to item i of buttonList
								if selected of buttonOfLastSelected then
									set indexOfLastButton to i
									set lastSelectedButtonFound to true
									exit repeat
								end if
							end if
						end repeat
						
						-- ���ҵ�����һ��������Ϣ�洢������
						if not lastSelectedButtonFound then
							set indexOfLastButton to defaultIndexOfLastButton
						end if
						
						-- �����Ƥ��
						try
							click buttonOfEraser
							-- ���������ļ�
							set configContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>indexOfEraser</key>
	<integer>" & indexOfEraser & "</integer>
	<key>indexOfLastButton</key>
	<integer>" & indexOfLastButton & "</integer>
</dict>
</plist>"
							do shell script "echo " & quoted form of configContent & " > " & quoted form of plistFilePath
						on error
							display dialog "�л�ʧ��,����Ƶ�����!"
						end try
					end if
				end if
			end if
		end if
	end tell
end tell