#include <futurocube>

new motion

#define SELECTED_COLOR 0x80808000
#define PIECE_COLOR BLUE

new selected = -1

new sides_w[6]
new sides_p[6]

new pieces[5][9] = [
    [0, 0, 0, 
     0, 1, 0, 
     0, 1, 0],
  
    [0, 0, 0, 
     0, 1, 1, 
     0, 1, 0],
  
    [0, 0, 0, 
     1, 1, 1, 
     0, 1, 0],
  
    [0, 1, 0, 
     0, 1, 0, 
     0, 1, 0],

    [0, 1, 0, 
     1, 1, 1, 
     0, 1, 0]
]

draw_piece(i)
{
    new w,j,r,c,p

    p = sides_p[i]

    if(p==-1)
    {
        return
    }

    w = sides_w[i]
    WalkerMove(w, STEP_FORWARD)
    WalkerMove(w, STEP_LEFT)

    if(selected == i) 
    {
        SetColor(SELECTED_COLOR)
    }
    else 
    {
        SetColor(PIECE_COLOR)
    }

    j=0
    for(r=0;r<3;r++)
    {
        for(c=0;c<3;c++)
        {
            if(pieces[p][j])
            {
                DrawPoint(w)
            }
            WalkerMove(w, STEP_RIGHT)
            j++
        }
        WalkerMove(w, STEP_BACKWARDS)
        WalkerMove(w, STEP_LEFT)
        WalkerMove(w, STEP_LEFT)
        WalkerMove(w, STEP_LEFT)
    }
}

draw_puzzle()
{
    ClearCanvas()

    new i
    for(i=0;i<6;i++)
    {
        draw_piece(i)
    }
}

rotate(w,r)
{
    new i
    for(i=0;i<r;i++)
    {
        WalkerTurn(w,TURN_RIGHT)
    }
    return w
}

check(s,i,step, draw = 1)
{
    new w = _w(s,i)
    if(ReadCanvas(w) != 0)
    {
        WalkerMove(w, step)
        if(ReadCanvas(w) == 0) 
        {
            if(draw)
            {
                WalkerMove(w, OppositeStep(step))
                SetColor(RED)
                DrawPoint(w)
            }
            return 1
        }            
    }
    return 0
}

validate_puzzle()
{
    new fault = 0
    new s
    for(s=0;s<6;s++)
    {
        fault += check(s,1,STEP_FORWARD, s != selected)
        fault += check(s,3,STEP_LEFT, s != selected)
        fault += check(s,5,STEP_RIGHT, s != selected)
        fault += check(s,7,STEP_BACKWARDS, s != selected)
    }
    return (fault == 0)
}

randomize_puzzle()
{
    new w1,w2
    new s1,s2
    new step1, step2, dx, dy
    new a, i

    Play("puzzle_shuffeling")

    for(i=0;i<50;i++)
    {
        s1 = GetRnd(6)
        do 
        {
            do
            {
                s2 = GetRnd(6)        
            } while (s2 == s1)

            w1 = sides_w[s1]
            w2 = sides_w[s2]
            step1 = WalkerDiff(w1, w2, dx,dy)
            step2 = WalkerDiff(w2, w1, dx,dy)

        } while(step1 == STEP_NOTHING)

        WalkerMove(w1,step1)
        WalkerMove(w1,step1)
        WalkerMove(w1,step1)

        WalkerMove(w2,step2)
        WalkerMove(w2,step2)
        WalkerMove(w2,step2)
            
        a = sides_p[s2]
        sides_p[s2] = sides_p[s1]
        sides_w[s2] = w1

        sides_p[s1] = a
        sides_w[s1] = w2

        draw_puzzle()
        validate_puzzle()
        PrintCanvas()                        

        Delay(100)
    }

}


new first_time = 1

game_loop()
{
    selected = -1

    if(first_time)
    {
        first_time = 0
        generate_puzzle()        
    }
    draw_puzzle()
    validate_puzzle()
    PrintCanvas()

    Play("puzzle_restart")

    new loop = 1
    while(loop)
    {
        motion = Motion()
        if(motion)
        {
            if(eTapSideOK())
            {
                if(_is(motion, TAP_DOUBLE))
                {
                    if(eTapToBot())
                    {
                        Quiet()
                        ClearCube()
                        Play("puzzle_generating");
                        generate_puzzle()        
                        draw_puzzle()
                        validate_puzzle()
                        PrintCanvas()                
                        Play("puzzle_restart")        
                    }
                    else if(eTapToTop())
                    {
                        Quiet()
                        randomize_puzzle()
                        loop = 0
                    }
                }                
            }
            AckMotion()
        }
        Sleep()
    }

    Quiet()

    new dx,dy,s,step1,step2,w1,w2
    new a

    new done = 0
    while(!done)
    {
        motion = Motion()

        if(motion)
        {
            if(eTapSideOK())
            {
                s = eTapSide()
                if(selected == -1) 
                {
                    if(!eTapToBot())
                    {
                        Play("cube_move")
                        selected = s
                    }
                }
                else 
                {
                    if(selected == s)
                    {
                        selected = -1
                    }
                    else 
                    {
                        Play("cube_rubik")

                        w1 = sides_w[selected]
                        w2 = sides_w[s]
                        step1 = WalkerDiff(w1, w2, dx,dy)
                        step2 = WalkerDiff(w2, w1, dx,dy)
                        if(step1 == STEP_NOTHING)
                        {
                            SetColor(RED) 
                            DrawSide(s)
                            PrintCanvas()
                            Delay(500)
                        }
                        else 
                        {
                            WalkerMove(w1,step1)
                            WalkerMove(w1,step1)
                            WalkerMove(w1,step1)

                            WalkerMove(w2,step2)
                            WalkerMove(w2,step2)
                            WalkerMove(w2,step2)
                            
                            a = sides_p[s]
                            sides_p[s] = sides_p[selected]
                            sides_w[s] = w1
                            sides_p[selected] = a
                            sides_w[selected] = w2

                            selected = -1
                        }
                    }
                }
            }

            AckMotion()
            motion = 0
        }

        draw_puzzle()
        done = validate_puzzle()
        PrintCanvas()

        Sleep()
    }

    Delay(500)

    Play("clapping")

    ClearCanvas()
    SetColor(WHITE)
    DrawCube()
    ClearCube()
    FlashCanvas(1,2,1)

    Delay(800)

    selected = -1
    draw_puzzle()
    validate_puzzle()
    PrintCanvas()

    WaitPlayOver()
}

// --- FACTORY ---

gen_clear_piece(i)
{
    new j
    SetColor(0)
    for(j=0;j<9;j++)
    {
        DrawPoint(_w(i,j))
    }
}

gen_draw_piece(i)
{
    SetColor(PIECE_COLOR)

    new w,j,r,c,p

    p = sides_p[i]

    if(p==-1)
    {
        return
    }

    w = sides_w[i]
    WalkerMove(w, STEP_FORWARD)
    WalkerMove(w, STEP_LEFT)

    //SetColor(0x10101000)

    j=0
    for(r=0;r<3;r++)
    {
        for(c=0;c<3;c++)
        {
            if(pieces[p][j])
            {
                DrawPoint(w)
            }
            WalkerMove(w, STEP_RIGHT)
            j++
        }
        WalkerMove(w, STEP_BACKWARDS)
        WalkerMove(w, STEP_LEFT)
        WalkerMove(w, STEP_LEFT)
        WalkerMove(w, STEP_LEFT)
    }
}

gen_check_con(s,i,step)
{
    new w1 = _w(s,i)
    new w2 = _w(s,i)
    WalkerMove(w2, step)

    if(ReadCanvas(w1) == ReadCanvas(w2))
    {
        return 1
    }
    return 0
}

gen_is_con(s,i,step)
{
    new w = _w(s,i)
    WalkerMove(w, step)

    if(ReadCanvas(w) != 0)
    {
        return 1
    }
    return 0
}

gen_validate_side(s)
{
    new i = 0
    i += gen_is_con(s,1,STEP_FORWARD)
    i += gen_is_con(s,3,STEP_LEFT)
    i += gen_is_con(s,5,STEP_RIGHT)
    i += gen_is_con(s,7,STEP_BACKWARDS)
    return (i > 0)
}

gen_print()
{
    PrintCanvas()                        
    Delay(20)
}

generate_puzzle()
{
    new i
    for(i=0;i<6;i++)
    {
        sides_p[i] = -1
        sides_w[i] = _w(i,4)
    }

    new check_ok
    for(;;)
    {
        ClearCanvas()

        // SIDE 0
        sides_p[0] = GetRnd(5)
        sides_w[0] = rotate(sides_w[0],GetRnd(4))
        gen_draw_piece(0)
        gen_print()                        


        // SIDE 1
        sides_p[1] = GetRnd(5)
        sides_w[1] = rotate(sides_w[1],GetRnd(4))
        gen_draw_piece(1)
        gen_print()                        

        // SIDE 2
        check_ok = 0
        for(i=0;i<100;i++)
        {
            sides_p[2] = GetRnd(5)
            sides_w[2] = rotate(sides_w[2],GetRnd(4))
            gen_draw_piece(2)
            gen_print()                        
            if(gen_check_con(2,3,STEP_LEFT) && gen_check_con(2,5,STEP_RIGHT))
            {
                check_ok = 1
                break
            }
            gen_clear_piece(2)
        }
        //printf("Side 2 steps: %d\n",i)
        if(check_ok == 0)
        {
            //printf("Side 2 not done\n")
            continue
        }

        // SIDE 3
        check_ok = 0
        for(i=0;i<100;i++)
        {
            sides_p[3] = GetRnd(5)
            sides_w[3] = rotate(sides_w[3],GetRnd(4))
            gen_draw_piece(3)
            gen_print()                        
            if(gen_check_con(3,3,STEP_LEFT) && gen_check_con(3,5,STEP_RIGHT))
            {
                check_ok = 1
                break
            }
            gen_clear_piece(3)
        }
        //printf("Side 3 steps: %d\n",i)
        if(check_ok == 0)
        {
            //printf("Side 3 not done\n")
            continue
        }

        // SIDE 4
        if(!gen_validate_side(4))
        {
            //printf("Side 4 has no connections\n")
            continue
        }
        check_ok = 0
        for(i=0;i<100;i++)
        {
            sides_p[4] = GetRnd(5)
            sides_w[4] = rotate(sides_w[4],GetRnd(4))
            gen_draw_piece(4)
            gen_print()                        
            if(gen_check_con(4,1,STEP_FORWARD) && gen_check_con(4,3,STEP_LEFT) && gen_check_con(4,5,STEP_RIGHT) && gen_check_con(4,7,STEP_BACKWARDS))
            {
                check_ok = 1
                break
            }
            gen_clear_piece(4)
        }
        //printf("Side 4 steps: %d\n",i)
        if(check_ok == 0)
        {
            //printf("Side 4 not done\n")
            continue
        }

        // SIDE 5
        if(!gen_validate_side(5))
        {
            //printf("Side 5 has no connections\n")
            continue
        }
        check_ok = 0
        for(i=0;i<100;i++)
        {
            sides_p[5] = GetRnd(5)
            sides_w[5] = rotate(sides_w[5],GetRnd(4))
            gen_draw_piece(5)
            gen_print()                        
            if(gen_check_con(5,1,STEP_FORWARD) && gen_check_con(5,3,STEP_LEFT) && gen_check_con(5,5,STEP_RIGHT) && gen_check_con(5,7,STEP_BACKWARDS))
            {
                check_ok = 1
                break
            }
            gen_clear_piece(5)
        }
        //printf("Side 5 steps: %d\n",i)
        if(check_ok == 0)
        {
            //printf("Side 5 not done\n")
            continue
        }

        break
    }
    WaitPlayOver()
}

// ---------------

setup()
{    
    RegAllSideTaps()          
    RegMotion(TAP_DOUBLE) 
}

#define C0   0x00000000
#define C1   PIECE_COLOR

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,4,
    C0,C1,C0,
    C0,C1,C1,
    C0,C1,C0,
    ''puzzle_title'',''puzzle_desc'']

main()
{
    ICON(icon)
    setup()
    for(;;)
    {
        game_loop()
    }
} 

