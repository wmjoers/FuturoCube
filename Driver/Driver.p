#include <futurocube>

new motion
new topside, leftside, rightside
new side

new player_w
new player_lane

new lane_1_w, lane_2_w, lane_3_w
new car_1_w, car_2_w
new car_1_step, car_2_step
new car_1_lane, car_2_lane

new digit_10_w
new digit_1_w

new level
new speed
new score


move(&walker, steps=1, step=STEP_FORWARD)
{
    new i
    for(i=0;i<steps;i++)
    {
        WalkerMove(walker, step)
    }
}

get_lane(idx)
{
    if(idx == 0)
    {
        return lane_1_w
    }
    else if(idx == 1)
    {
        return lane_2_w
    }
    else if(idx == 2)
    {
        return lane_3_w
    }
    else
    {
        return 0
    }
}

draw_player()
{
    SetColor(BLUE)
    new w = player_w
    DrawPoint(w)
    WalkerMove(w)
    DrawPoint(w)
}

draw_cars()
{
    new w
    SetColor(RED)
    if(car_1_w)
    {
        w = car_1_w
        DrawPoint(w)
        WalkerMove(w,STEP_BACKWARDS)        
        DrawPoint(w)
    }
    if(car_2_w)
    {
        w = car_2_w
        DrawPoint(w)
        WalkerMove(w,STEP_BACKWARDS)        
        DrawPoint(w)
    }
}

draw_score()
{
    new s = score % 100
    SetIntensity(5)
    SetColor(0xFFFF0000)
    DrawDigit(digit_10_w, s/10)
    DrawDigit(digit_1_w, s % 10)
    SetIntensity(256)
}

draw_game()
{
    ClearCanvas()

    draw_player()
    draw_cars()
    draw_score()

    PrintCanvas()
}

update_player()
{    
    if(motion)
    {
        if(eTapSideOK())
        {
            side = eTapSide()

            if(side == leftside && player_lane > 0)
            {
                player_lane--
                WalkerMove(player_w, STEP_LEFT)
            }
            else if(side == rightside && player_lane < 2)
            {
                player_lane++
                WalkerMove(player_w, STEP_RIGHT)
            }
            motion = 0
            AckMotion()
        } 
    }
}

setup_next_level()
{
    new i
    if(level < 10)
    {
        car_1_lane = GetRnd(3)
        car_1_w = get_lane(car_1_lane)
        car_1_step = 0
        car_2_w = 0
    }
    else if(level >= 10 && level < 20)
    {
        car_1_lane = GetRnd(3)
        car_1_w = get_lane(car_1_lane)
        car_1_step = 0
        
        do 
        {
            car_2_lane = GetRnd(3)
        } while (car_1_lane == car_2_lane)
        car_2_w = get_lane(car_2_lane)
        car_2_step = 0

        for(i=0;i<GetRnd(2)+1;i++) {
            WalkerMove(car_2_w,STEP_BACKWARDS)
            car_2_step--
        }
    }
    else if(level >= 20)
    {
        car_1_lane = GetRnd(3)
        car_1_w = get_lane(car_1_lane)
        car_1_step = 0
        
        do 
        {
            car_2_lane = GetRnd(3)
        } while (car_1_lane == car_2_lane)
        car_2_w = get_lane(car_2_lane)
        car_2_step = 0

        for(i=0;i<GetRnd(4)+1;i++) {
            WalkerMove(car_2_w,STEP_BACKWARDS)
            car_2_step--
        }
    }

    if(level < 10)
    {
        speed-=10
    }
    else if(level >= 20 && level < 30)
    {
        speed-=5
    }
    else if(level >= 30)
    {
        speed-=1
    }

    level++
}

new playing_1, playing_2

update_cars()
{
    if(!car_1_w && !car_2_w) 
    {
        setup_next_level()
    }

    if(GetTimer(0) == 0)
    {
        if(car_1_w)
        {
            WalkerMove(car_1_w)
            car_1_step++
            if(car_1_step >= 8)
            {
                score++
                Play("beep")
                car_1_w = 0
                car_1_step = 0
            }

        }
        if(car_2_w)
        {
            WalkerMove(car_2_w)
            car_2_step++
            if(car_2_step >= 8)
            {
                score++
                Play("beep")
                car_2_w = 0
                car_2_step = 0
            }
        }

        SetTimer(0,speed)
    }

    if(car_1_w && car_1_lane == player_lane && car_1_step >= 5 && car_1_step <= 7)
    {
        return 1        
    }
    else if(car_2_w && car_2_lane == player_lane && car_2_step >= 5 && car_2_step <= 7)
    {
        return 1        
    }

    if(car_1_w && car_1_step >= 3)
    {
        if(!playing_1)
        {
            playing_1 = 1
            Play("passing")
        }
    }
    else
    {
        playing_1 = 0        
    }

    if(car_2_w && car_2_step >= 3)
    {
        if(!playing_2)
        {
            playing_2 = 1
            if(car_1_step != car_2_step)
            {
                Play("passing")
            }
        }
    }
    else
    {
        playing_2 = 0        
    }

    return 0
}

reset_game()
{
       
    SetIntensity(256)

    level = 0
    speed = 400

    if(player_lane < 1)
    {
        player_lane++
        WalkerMove(player_w, STEP_RIGHT)
    }
    else if(player_lane > 1)
    {
        player_lane--
        WalkerMove(player_w, STEP_LEFT)
    }
    car_1_w = 0
    car_2_w = 0
    car_1_step = 0
    car_2_step = 0

    new t = 0
    SetTimer(0, 0)

    Play("_g_TAPTOSTART")

    for (;;)
    {
        Sleep()
        motion=Motion()

        if(motion)
        {
            if(eTapToTop())
            {
                score = 0
                draw_game()
                Delay(1000)
                return
            }
        }

        if(GetTimer(0)==0)
        {
            SetTimer(0, 300)
                
            draw_game()
            if(t == 0)
            {
                SetColor(0x30303000)
                DrawPoint(_w(topside,0))
                DrawPoint(_w(topside,2))
                DrawPoint(_w(topside,4))
                DrawPoint(_w(topside,6))
                DrawPoint(_w(topside,8))
                SetColor(0x05050500)
                DrawPoint(_w(topside,1))
                DrawPoint(_w(topside,3))
                DrawPoint(_w(topside,5))
                DrawPoint(_w(topside,7))

                t=1
            }
            else
            {
                SetColor(0x05050500)
                DrawPoint(_w(topside,0))
                DrawPoint(_w(topside,2))
                DrawPoint(_w(topside,4))
                DrawPoint(_w(topside,6))
                DrawPoint(_w(topside,8))
                SetColor(0x30303000)
                DrawPoint(_w(topside,1))
                DrawPoint(_w(topside,3))
                DrawPoint(_w(topside,5))
                DrawPoint(_w(topside,7))
                t=0
            }
            PrintCanvas()
        }

    }   
}

new say_100[]{} = ["","100","200","300","400","500","600","700","800","900"]
new say_10[]{} = ["","","_s_20","_s_30","_s_40","_s_50","_s_60","_s_70","_s_80","_s_90"]
new say_1[]{} = ["","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"]

show_score()
{
    Play("_s_SCOREIS")
    WaitPlayOver()

    new s = score

    if (score == 0)
    {
        Play("_t_UFF")
        WaitPlayOver()
    }
    if(s >= 100) 
    {
        Play(say_100[s/100])
        WaitPlayOver() 
        s = s - (s/100)*100       
    }
    if(s >= 20)
    {
        Play(say_10[s/10])
        WaitPlayOver() 
        s = s - (s/10)*10       
    }
    if(s <= 19)
    {
        Play(say_1[s])
        WaitPlayOver() 
    }

    Delay(2000)
        
}


game_loop()
{

    new crash = 0

    reset_game()
    Play("_c_RUN")
    WaitPlayOver()
    
    for (;;)
    {
        if(IsPlayAtChOver(3))
        {
            PlayAtCh(3,"_d_DO")
        }

        motion=Motion()

        update_player()
        crash = update_cars()
        draw_game()

        if(motion) 
        {
            AckMotion()
        }

        if(crash)
        {
            crash=0
            Quiet()
            PlayAtCh(0,"_g_CRASH")
            Vibrate(600)
            Delay(2000)
            show_score()
            reset_game()
            Play("_c_RUN")
            WaitPlayOver()
    }

        Sleep()
    }   
}

setup()
{
    RegAllSideTaps()          

    topside = _side(GetCursor())

    new w

    w = _w(topside,4)
    move(w,2, STEP_BACKWARDS)
    WalkerMove(w, STEP_LEFT)
    lane_1_w = w
    WalkerMove(w, STEP_RIGHT)
    lane_2_w = w
    WalkerMove(w, STEP_RIGHT)
    lane_3_w = w

    w = _w(topside,4)
    move(w,3)
    //frontside = _side(w)
    move(w,2, STEP_RIGHT)
    rightside = _side(w)
    move(w,4, STEP_LEFT)
    leftside = _side(w)
    move(w,2, STEP_RIGHT)

    player_w = w
    player_lane = 1    

    digit_1_w = _w(topside,4)
    move(digit_1_w,2)
    WalkerTurn(digit_1_w, TURN_LEFT)
    move(digit_1_w,2)    
    WalkerTurn(digit_1_w, TURN_LEFT)

    digit_10_w = _w(topside,4)
    move(digit_10_w,2)
    WalkerTurn(digit_10_w, TURN_RIGHT)
    move(digit_10_w,4)    
    WalkerTurn(digit_10_w, TURN_RIGHT)

}

#define C0   0x00000000
#define C1   0x0000FF00
#define C2   0xFF000000

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,4,
    C2,C0,C0,
    C2,C0,C1,
    C0,C0,C1,
    ''title'',''description'']

main()
{
    ICON(icon)
    setup()
    game_loop()

} 
