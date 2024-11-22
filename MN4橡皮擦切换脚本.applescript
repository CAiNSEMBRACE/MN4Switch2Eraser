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

setMN4Front()
try
	tell application "System Events"
		tell process "MarginNote 4"
			set windowList to windows
			if (count of windowList) is 0 then
				display dialog "No windows found of the MarginNote 4."
			else
				set targetWindow to item (count of windows) of windows
				try
					set buttonList to buttons of scroll area 1 of group 3 of group 3 of group 1 of group 1 of group 1 of group 1 of group 1 of targetWindow
				end try
				set countOfButtons to count of buttonList
				if countOfButtons is 0 then
					display dialog "No buttons found of the MarginNote 4."
				else
					--ע��,�뽫���������4���������Ƥ���ı��
					--��1��ʼ��,������Ƥ��
					--����:��Ĺ��������ǡ��ֱʡ��ֱʡ��ʱʡ�Ǧ�ʡ���Ƥ��,�ͽ��·�������4����5
					set indexOfEraser to 4
					set buttonOfEraser to item indexOfEraser of buttonList
					if selected of buttonOfEraser then
						set buttonOfFirstPen to item 1 of buttonList
						try
							click buttonOfFirstPen
						on error
							--display dialog "�л�ʧ��,����Ƶ�����!"
						end try
					else
						try
							click buttonOfEraser
						on error
							--display dialog "�л�ʧ��,����Ƶ�����!"
						end try
					end if
				end if
			end if
		end tell
	end tell
end try