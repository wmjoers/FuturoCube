#include <futurocube>

new motion
new cursor
new player
new px,py
new rx,ry
new cur_side
new time

#define WALL_COLOR 0x10101000
#define PLAYER_COLOR BLUE
#define VISITED_COLOR 0x00001000
#define GOAL_COLOR GREEN

#define LEFT 1
#define TOP 2
#define RIGHT 4
#define BOTTOM 8
#define VISITED 16
#define MG_VISITED 32

#define ROTATION_0 0
#define ROTATION_90 1
#define ROTATION_180 2
#define ROTATION_270 3

#define MAZE_MAX_TIME 999
#define MAZE_SIZE 10
new maze[MAZE_SIZE][MAZE_SIZE]

new room_rotation = ROTATION_0
new rotation_mapping[4][9] = 
[
    [0,1,2,3,4,5,6,7,8],
    [6,3,0,7,4,1,8,5,2],
    [8,7,6,5,4,3,2,1,0],
    [2,5,8,1,4,7,0,3,6]
]

find_rotation(expected_i, actual_i)
{
    new i
    for(i=0; i<4; i++)
    {
        if(rotation_mapping[i][expected_i]==actual_i) 
        {
            return i
        }
    }
    return 0
}

draw_room(s)
{   
    SetColor(WALL_COLOR)
    DrawSquare(_w(s,4))
    new r = maze[rx][ry]

    if(r & TOP)
    {    
        if (ry < MAZE_SIZE-1 && (maze[rx][ry+1] & VISITED))
        {
            SetColor(VISITED_COLOR)
        }
        else
        {
            SetColor(0)
        }        

        DrawPoint(_w(s, rotation_mapping[room_rotation][1]))
    }
    if(r & RIGHT)
    {
        if (rx < MAZE_SIZE-1 && (maze[rx+1][ry] & VISITED))
        {
            SetColor(VISITED_COLOR)
        }
        else
        {
            SetColor(0)
        }        
        DrawPoint(_w(s, rotation_mapping[room_rotation][5]))
    }
    if(r & BOTTOM)
    {
        if (ry > 0 && (maze[rx][ry-1] & VISITED))
        {
            SetColor(VISITED_COLOR)
        }
        else
        {
            SetColor(0)
        }        
        DrawPoint(_w(s, rotation_mapping[room_rotation][7]))
    }
    if(r & LEFT)
    {
        if (rx > 0 && (maze[rx-1][ry] & VISITED))
        {
            SetColor(VISITED_COLOR)
        }
        else
        {
            SetColor(0)
        }
        DrawPoint(_w(s, rotation_mapping[room_rotation][3]))
    }
    if(maze[rx][ry] & VISITED)
    {
        SetColor(VISITED_COLOR)
        DrawPoint(_w(s, 4))        
    }

}

move_player()
{
    new dx, dy, step
    step = WalkerDiff(player, cursor, dx, dy)

    WalkerMove(player, step)
    new c = ReadCanvas(player)
    if(c != 0 && c != VISITED_COLOR && c != GOAL_COLOR)
    {
        WalkerMove(player, OppositeStep(step))    
        return 0
    }

    new expected = -1
    new moving = 0
    if(step == STEP_FORWARD)
    {
        expected = 7
        moving = 1
        py++
    }
    else if(step == STEP_BACKWARDS)
    {
        expected = 1
        moving = 1
        py--
    }
    else if(step == STEP_RIGHT)
    {
        expected = 3
        moving = 1
        px++
    }
    else if(step == STEP_LEFT)
    {
        expected = 5
        moving = 1
        px--
    }
    rx = px/3
    ry = py/3

    if(moving)
    {
        //debug_print_step(step)
        //printf("Player: %d, %d\n", px, py)
        //printf("Room: %d, %d\n", rx, ry)

        if(_square(player) == 4 && !(maze[rx][ry] & VISITED))
        {
            maze[rx][ry] = maze[rx][ry] | VISITED
        }

        if(_side(player) != cur_side)
        {
            cur_side = _side(player)
            room_rotation = find_rotation(expected,_square(player))
            //printf("Exp:%d, Act:%d\n",expected,_square(player))
            //debug_print_room(maze[rx][ry])
        }
        return 1
    }
    return 0
}

debug_draw_cursor()
{
    SetColor(RED)
    DrawPoint(cursor)
}

debug_draw_zero()
{
    new i
    for(i=0;i<6;i++)
    {
        SetColor(GREEN)    
        DrawPoint(_w(i, 0))
    }
}

new step_names[]{} = [
    "STEP_NOTHING",
    "STEP_FIRST",
    "STEP_FORWARD",
    "STEP_BACKWARDS",
    "STEP_RIGHT",
    "STEP_LEFT",
    "STEP_UPRIGHT",
    "STEP_UPLEFT",
    "STEP_DOWNRIGHT",
    "STEP_DOWNLEFT",
    "STEP_HEAD"
]

debug_print_step(step)
{
    printf("STEP: %s\n",step_names[step])
}

debug_print_room(r)
{
    new room[] = 
    [
        1, 1, 1,
        1, 0, 1,
        1, 1, 1
    ]

    if(r & TOP)
    {
        room[1] = 0
    }
    if(r & RIGHT)
    {
        room[5] = 0
    }
    if(r & BOTTOM)
    {
        room[7] = 0
    }
    if(r & LEFT)
    {
        room[3] = 0
    }

    printf("%d %d %d\n",room[0], room[1], room[2])
    printf("%d %d %d\n",room[3], room[4], room[5])
    printf("%d %d %d\n",room[6], room[7], room[8])
}

new say_100[]{} = ["","100","200","300","400","500","600","700","800","900"]
new say_10[]{} = ["","","_s_20","_s_30","_s_40","_s_50","_s_60","_s_70","_s_80","_s_90"]
new say_1[]{} = ["","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"]

say_score(score)
{
    Play("maze_your_time_is")
    WaitPlayOver()

    new s = score

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

    Play("maze_seconds")
    WaitPlayOver()
}


game_loop()
{   
    room_rotation = ROTATION_0
    cursor = GetCursor()
    cur_side = _side(cursor)
    player = _w(cur_side,4)
    px = 1
    py = 1
    rx = 0
    ry = 0

    maze[rx][ry] = maze[rx][ry] | VISITED

    ClearCanvas()
    draw_room(cur_side)
    SetColor(PLAYER_COLOR)
    DrawPoint(player)
    PrintCanvas()

    Play("maze_start")

    for(;;)
    {
        motion = Motion()
        if(motion) 
        {
            if(eTapSideOK())
            {
                if(eTapToTop())
                {
                    break;
                }
            }

            AckMotion()
            motion = 0
        }
        Sleep()
    }

    
    new flash_delay = 200

    Delay(flash_delay)

    SetColor(0)
    DrawPoint(player)
    PrintCanvas()
    Delay(flash_delay)
    SetColor(PLAYER_COLOR)
    DrawPoint(player)
    PrintCanvas()
    Play("beep")

    Delay(flash_delay)

    SetColor(0)
    DrawPoint(player)
    PrintCanvas()
    Delay(flash_delay)
    SetColor(PLAYER_COLOR)
    DrawPoint(player)
    PrintCanvas()
    Play("beep")


    Delay(flash_delay)

    SetColor(0)
    DrawPoint(player)
    PrintCanvas()
    Delay(flash_delay)
    SetColor(PLAYER_COLOR)
    DrawPoint(player)
    PrintCanvas()
    Play("bell2")

    //Play("clocktickfast")
    time = GetAppMsecs()


    new game_runnig = 1
    while(game_runnig)
    {
        motion = Motion()
        if(motion) 
        {
            AckMotion()
            motion = 0
        }

        cursor = GetCursor()

        ClearCanvas()
        draw_room(cur_side)
        move_player()

        //debug_draw_cursor()

        SetColor(PLAYER_COLOR)
        DrawPoint(player)

        if(rx == MAZE_SIZE-1 && ry == MAZE_SIZE-1)
        {
            SetColor(GOAL_COLOR)
            DrawPoint(_w(cur_side,4))

            if(_square(player)==4)
            {
                time = GetAppMsecs()-time
                Quiet()
                Play("fanfare_short")
                game_runnig = 0
            }            
        }

        if(((GetAppMsecs()-time)/1000) > MAZE_MAX_TIME)
        {
            time = GetAppMsecs()-time
            Quiet()
            game_runnig = 0
        }

        //debug_draw_zero()

        PrintCanvas()

        Sleep()
    }

    WaitPlayOver() 

    if((time/1000) <= MAZE_MAX_TIME)
    {
        say_score(time/1000)
    }
    else 
    {
        Play("maze_time_is_up")            
        WaitPlayOver()
    }
}

// --- MAZE GENERATOR ---

#define MAZE_NODES (MAZE_SIZE*MAZE_SIZE)

new gm_stack_x[MAZE_NODES]
new gm_stack_y[MAZE_NODES]
new gm_stackidx=0

gm_push(x,y)
{
    gm_stack_x[gm_stackidx]=x
    gm_stack_y[gm_stackidx]=y
    gm_stackidx++
}

gm_pop(&x, &y)
{
    gm_stackidx--
    x = gm_stack_x[gm_stackidx]
    y = gm_stack_y[gm_stackidx]
}

new gm_dirs[] = [LEFT, TOP, RIGHT, BOTTOM] 

gm_get_random_dir(mx, my)
{
    new dirs = 0

    // Check left
    if (mx > 0 && !(maze[mx-1][my] & MG_VISITED))
    {
        dirs = dirs | LEFT
    }
    // Check right
    if (mx < MAZE_SIZE-1 && !(maze[mx+1][my] & MG_VISITED))
    {
        dirs = dirs | RIGHT        
    }
    // Check bottom
    if (my > 0 && !(maze[mx][my-1] & MG_VISITED))
    {
        dirs = dirs | BOTTOM
    }
    // Check top
    if (my < MAZE_SIZE-1 && !(maze[mx][my+1] & MG_VISITED))
    {
        dirs = dirs | TOP        
    }

    if(dirs == 0)
    {
        return 0
    }

    new d 
    for(;;)
    {
        d = gm_dirs[GetRnd(4)]
        if(dirs & d)
        {
            return d
        }
    }
}

gm_opposite_dir(dir)
{
    if(dir == TOP)
    {
        return BOTTOM
    }
    else if(dir == BOTTOM)
    {
        return TOP
    }
    else if(dir == LEFT)
    {
        return RIGHT
    }
    else if(dir == RIGHT)
    {
        return LEFT
    }    
    else
    {
        return 0
    }
}

generate_maze_anim()
{
    new c = GetCursor()
    new w = _w(_side(c),4)
    new i, r

    Play("maze_generate")

    SetColor(PLAYER_COLOR)
    ClearCanvas()
    for(i=0;i<100;i++)
    {       

        motion = Motion()
        if(motion)
        {
            AckMotion()
        }

        AdjCanvas(-10)
        DrawPoint(w)
        DrawPoint(GetSymmetrySquare(w))

        WalkerMove(w,STEP_FORWARD)
        r = GetRnd(6)
        if(r == 0)
        {
            WalkerTurn(w, TURN_LEFT)
        }
        else if(r == 1)
        {
            WalkerTurn(w, TURN_RIGHT)
        }

        PrintCanvas()
        Delay(20)
  
        Sleep()
    }
}

generate_maze()
{
    new mx, my
    new dir

    generate_maze_anim()

    for(mx = 0; mx < MAZE_SIZE; mx++)
    {
        for(my = 0; my < MAZE_SIZE; my++)
        {
            maze[mx][my]= 0
        }        
    }

    mx = 0
    my = 0
    maze[mx][my]= maze[mx][my] | MG_VISITED

    for(;;)
    {
        dir = gm_get_random_dir(mx, my)
        if(dir) 
        {
            // Store current location
            gm_push(mx, my)
            // Open doorway
            maze[mx][my]= maze[mx][my] | dir
            // Move to node
            if(dir == RIGHT) 
            { 
                mx++ 
            }
            if(dir == LEFT) 
            { 
                mx--
            }
            if(dir == TOP) 
            { 
                my++ 
            }
            if(dir == BOTTOM) 
            { 
                my--
            }
            // Set 
            maze[mx][my]= maze[mx][my] | MG_VISITED
            maze[mx][my]= maze[mx][my] | gm_opposite_dir(dir)
        }
        else 
        {
            if(gm_stackidx == 0)
            {
                break
            }
            else 
            {
                gm_pop(mx, my)
            }
        }
    }    
}

cleanup_maze()
{
    new mx, my

    for(mx = 0; mx < MAZE_SIZE; mx++)
    {
        for(my = 0; my < MAZE_SIZE; my++)
        {
            maze[mx][my]= maze[mx][my] & ~VISITED            
        }        
    }
}

// ----------------------

setup()
{
    RegAllSideTaps()          
    RegMotion(TAP_DOUBLE)
    SetIntensity(256)
}

#define C0   0x00000000
#define C1   WALL_COLOR
#define C2   PLAYER_COLOR

new icon[]=[ICON_MAGIC1,ICON_MAGIC2,3,4,
    C1,C1,C1,
    C1,C2,C0,
    C1,C0,C1,
    ''maze_title'',''maze_desc'']

main()
{
    ICON(icon)
    setup()
    generate_maze()

    new loop
    for(;;)
    {
        game_loop()

        Delay(1000)

        Play("maze_restart")

        loop = 1
        while(loop)
        {
            motion = Motion()
            if(motion) 
            {
                if(eTapSideOK())
                {
                    if(_is(motion, TAP_DOUBLE))
                    {
                        if(eTapToTop())
                        {   
                            Quiet()
                            loop=0
                        }
                        if(eTapToBot())
                        {
                            Quiet()
                            generate_maze()
                            loop=0
                        }
                    }
                }

                AckMotion()
                motion = 0
            }
            Sleep()
        }
        cleanup_maze()
    }

} 
