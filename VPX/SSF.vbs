'**********************************************************************************************************
'
'	SSF
'
'	Factored and enhanced SSF routines
'	Grouped related SSF functions into a single common script
'
'	Enhanced surround mix functions to permit pan and fade curve selection
'	Intelligent xpos, ypos functions to find the location of any object
'	Include JP's Ball rolling & Rothbauerw's routines factored out parameter constants
'
'	To use:
'
'	On Error Resume Next
'	ExecuteGlobal GetTextFile("SSF.vbs")
'	If Err Then MsgBox "SSF.vbs missing"
'	Set ssfTable = x					' Optional for earlier than 10.7 if the table is not table1
'	On Error Goto 0
'
'
'	Functions:
'
'	Sub PlaySoundAt(sound, tableobj)			' Play the sound once at the object, or ball if object doesn't have .x,.y
'	Sub PlaySoundAtVol(sound, tableobj, Vol)		' " + specify volume 0-1
'	Sub PlaySoundAtRPitch(sound, tableobj, RPitch)		' " + specify random pitch 0-1
'
'	Sub PlaySoundAtBall(sound)				' Play the sound once at the activeball, speed affects volume/pitch
'	Sub PlayExistingSoundAtBall(sound)			' 	" + uses the existing sound
'	Sub PlayExistingSoundAtBallVol(sound, VolMult)		' 	" + specify volume multiplier
'
'	Change log
'	----------
'	R.Lincoln	April 2021	Creation
'	R.Lincoln	June 2021	Add in standard ball functions & intelligent xpos/ypos
'	R.Lincoln	July 2021	Use vpx 10.7 and later ActiveTable object
'	R.Lincoln	October 2021	Add Vol param variously and include JPS ball rolling routine
'	R.Lincoln	October 2021	Support versions <10.7 by setting up ActiveTable pointer
'	R.Lincoln	October 2021	Amend ball rolling to include ramps
'	R.Lincoln	October 2021	Add x,y independent sound curves
'
'**********************************************************************************************************
option Explicit


'	ActiveTable is only available after 10.7
'	Assumes table1, can be overridden for tables with different names
'
Dim ssfTable
If Version > 10700 Then
	set ssfTable = ActiveTable
else
	on error resume next
	set ssfTable = table1			' not always table1, so can override at the caller
	on error goto 0
End If

'	Maximum number of balls for ball rolling sounds
'
Dim ssfBalls
ssfBalls = 5

'	Multiplier for the ball rolling sound volume
'	Some tables are strangely loud - so allows overriding later
'
Dim ssfRollingVol
ssfRollingVol = 1


'	Rate is the power to use on the sound curve: 2 gives smooth transition
'		<1 	Prefers off centre:	-1 and +1 mix
'		>1	prefers centre:		0 mix
'
'		1	Linear
'		2	Clear separation with smooth centre mix transition
'	=>	10	Default on most existing table scripts very heavy centre mix
'
Dim ssfCurveRateX, ssfCurveRateY
ssfCurveRateX = 2
ssfCurveRateY = 1



'**********************************************************************************************************


'	Plot position on an exponential curve against range
'	Returns -1..0..+1
'
Function AudioCurve(range, position, rate)
	dim tmp
	tmp = (position *2 / range) -1
	AudioCurve = sgn(tmp) * abs(tmp) ^rate
End Function

'	Find the x/y position of an object
'	If it doesn't have position methods use the ball position
'
Function xpos(tableobj)
	on error resume next
	xpos = activeball.x
	xpos = tableobj.x
End Function

Function ypos(tableobj)
	on error resume next
	ypos = activeball.y
	ypos = tableobj.y
End Function

'	Simplified pan and fade based on a specific object.
'	Returns -1..0..1
'
Function AudioFade(tableobj)
	AudioFade = AudioCurve(ssfTable.Height, ypos(tableobj), ssfCurveRateY)
End Function

Function AudioPan(tableobj)
	AudioPan = AudioCurve(ssfTable.Width, xpos(tableobj), ssfCurveRateX)
End Function


'	Standard PlaySoundAt functions
'
'	Uses core VPX:
'	PlaySound "name", loopcount, volume, pan, randompitch, pitch, useexisting, restart, fade
'

'	Any object
'
'	Useexisting off, restart on
'
Sub PlaySoundAt(sound, tableobj)
	PlaySound sound, 1, 1, AudioPan(tableobj), 0, 0, 0, 1, AudioFade(tableobj)
End Sub

Sub PlayExistingSoundAt(sound, tableobj)
	PlaySound sound, 1, 1, AudioPan(tableobj), 0, 0, 1, 0, AudioFade(tableobj)
End Sub

'	Per object adjust volume
Sub PlaySoundAtVol(sound, tableobj, Vol)
	PlaySound sound, 1, Vol, AudioPan(tableobj), 0, 0, 0, 1, AudioFade(tableobj)
End Sub

Sub PlaySoundAtRPitch(sound, tableobj, RPitch)
	PlaySound sound, 1, 1, AudioPan(tableobj), RPitch, 0, 0, 1, AudioFade(tableobj)
End Sub

Sub PlayRepeatSoundAtVol(sound, tableobj, vol)
	PlaySound sound, -1, vol, AudioPan(tableobj), 0, 0, 0, 1, AudioFade(tableobj)
End Sub


'	Ball location functions taking ball speed into account
'
'	Useexisting on/off, restart off
'
Function BallVel(ball)
	BallVel = sqr((ball.VelX ^2) + (ball.VelY ^2))
End Function

Function BallVol(ball)
	BallVol = BallVel(ball) ^3 /2000
End Function

Function BallPitch(ball)
	BallPitch = BallVel(ball) *20
End Function

Sub PlaySoundAtBall(sound)
	PlaySound sound, 0, BallVol(ActiveBall), AudioPan(ActiveBall), 0, BallPitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtBallVol(sound, VolMult)
	PlaySound sound, 0, BallVol(ActiveBall) * VolMult, AudioPan(ActiveBall), 0, BallPitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtBallPitch(sound, pitch)
	PlaySound sound, 0, BallVol(ActiveBall), AudioPan(ActiveBall), 0, pitch, 0, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtBallVolPitch(sound, volMult, pitch)
	PlaySound sound, 0, BallVol(ActiveBall) * volMult, AudioPan(ActiveBall), 0, pitch, 0, 0, AudioFade(ActiveBall)
End Sub

Sub PlayExistingSoundAtBall(sound)
	PlaySound sound, 0, BallVol(ActiveBall), AudioPan(ActiveBall), 0, BallPitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub PlayExistingSoundAtBallVol(sound, VolMult)
	PlaySound sound, 0, BallVol(ActiveBall) * VolMult, AudioPan(ActiveBall), 0, BallPitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub


'**********************************************************************************************************
'
'      JP's VP10 Rolling Sounds
'

' Requirements
'
' A timer called RollingTimer. With a fast interval, like 10
' One collision sound, in this script is called fx_collide
' As many sound files as max number of balls: fx_ballrolling0, fx_ballrolling1, fx_ballrolling2, fx_ballrolling3, etc


' Sounds are played based on the ball speed and position
' The routine checks first for deleted balls and stops the rolling sound.
'
' The For loop goes through all the balls on the table and checks for the ball speed and 
' if the ball is on the table (height lower than 30) then then it plays the sound
' otherwise the sound is stopped, like when the ball has stopped or is on a ramp or flying.
'
' The sound is played using the VOL, PAN and PITCH functions, so the volume and pitch of the sound
' will change according to the ball speed, and the PAN function will change the stereo position according
' to the position of the ball on the table.
'
ReDim rolling(ssfBalls)

Sub RollingTimer_Timer()
	Dim BOT, b
	BOT = GetBalls

	' Stop the sound of deleted balls
	For b = UBound(BOT) + 1 to UBound(rolling)
		If rolling(b) = True Then
			rolling(b) = False
			StopSound("fx_ballrolling" & b)
		End If
    	Next

	' Exit the sub if no balls on the table
	If UBound(BOT) = -1 Then Exit Sub

	' Play the rolling sound for each ball
	For b = 0 to UBound(BOT)
		If BallVel(BOT(b)) > 1 Then	' Moving ball
			rolling(b) = True
		        if BOT(b).z < 30 Then 	' ..on playfield
          			PlaySound("fx_ballrolling" & b), -1, BallVol(BOT(b)) *ssfRollingVol, AudioPan(BOT(b)), 0, BallPitch(BOT(b)), 1, 0, AudioFade(BOT(b))
		        Else 			' ..on raised ramp
				PlaySound("fx_ballrolling" & b), -1, BallVol(BOT(b)) *ssfRollingVol, AudioPan(BOT(b)), 0, BallPitch(BOT(b)) +30000, 1, 0, AudioFade(BOT(b))
			End If

		Else				' Not moving
			If rolling(b) = True Then
				rolling(b) = False
				StopSound("fx_ballrolling" & b)
			End If
		End If

		' Rothbauerw's dropping sounds
		'
		If BOT(b).VelZ < -1 and BOT(b).z < 55 and BOT(b).z > 27 Then	' Height adjust for ball drop sounds
            		PlaySound "fx_balldrop", 0, abs(BOT(b).velz) /17, AudioPan(BOT(b)), 0, BallPitch(BOT(b)), 1, 0, AudioFade(BOT(b))
        	End If
	Next
End Sub

' The collision is built in VP.
' You only need to add a Sub OnBallBallCollision(ball1, ball2, velocity) and when two balls collide they 
' will call this routine. What you add in the sub is up to you. As an example is a simple Playsound with volume and paning
' depending of the speed of the collision.
'
Sub OnBallBallCollision(ball1, ball2, velocity)
	PlaySound("fx_collide"), 0, velocity ^2 /2000, AudioPan(ball1), 0, BallPitch(ball1), 0, 0, AudioFade(ball1)
End Sub

'**********************************************************************************************************

