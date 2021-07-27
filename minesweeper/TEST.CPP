#include<iostream>
#include<conio.h>
#include<graphics.h>
#include<stdlib.h>
using namespace std;
int minefield[20][20];
int field_info[20][20];
int FIELD_SIZE = 6;
int FIELD_MINE_NO = 3;
int OFFSET_X = 25;
int OFFSET_Y = 2;
const int FIELD_MARKED = -2;
const int FIELD_UNMARKED = -1;
const int MINE_NOT_PRESENT = 0;
const int MINE_PRESENT = 1;
const int FIELD_CLEARED = -4;
const int FIELD_QUEUED = -3;
const int RESULT_EXIT = -1;
const int RESULT_WIN = 1;
const int RESULT_EXPLOSION = 2;
const char FIELD_CHAR = 219;
const char ZERO_MINES = ' ';
const char MINE = '';
const char FIELD_SELECT = 'S';
const char MINE_EXPLOSION[] = "BOOM!!!! MINE EXPLODED!!!";
const char GAME_WON[] = "Congrats !! You won !!";
const char GAME_EXIT[] = "Thanks for playing. Press any key to continue ....";
const char NEVER_TO_BE_PRINTED[] = "Abnormal result. Program AI crashed. You have exploded our minds. Congrats.";
const char WELCOME[] = "Welcome to Minesweeper";
const char INSTRUCT[] = "Instructions :";
const char INSTRUCT_MOVE[] = "Use 'w','a','s','d' to move selector";
const char INSTRUCT_CLEAR[] = "Use 't' to check a space for mine";
const char INSTRUCT_MINE[] = "Use 'm' to mark a space as possible mine";
const char INSTRUCT_GIVEUP[] = "Use 'p' to get solution";
const char DIFFICULTY[] = "Please select a difficulty :";
const char DIFFICULTY_1[] = "1. 6x6 , 9 mines";
const char DIFFICULTY_2[] = "2. 10x10 , 20 mines";
const char DIFFICULTY_3[] = "3. 20x20 , 40 mines";
const char CONTINUE[] = "Press any key to continue ...";

void printxy(char c,int x,int y)
{
	int xi=getx(),yi=gety();
	gotoxy(x+OFFSET_X,y+OFFSET_Y);
	cout<<c;
	gotoxy(xi,yi);
}

void print_centre(const char s[],int y)
{
	int len,j;
	for(len=0;s[len]!='\0';len++);
	gotoxy((80-len)/2,y);
	cout<<s;
}
void initialize()
{
	int i,j,k;
	for(i=0;i<FIELD_SIZE;i++)
		for(j=0;j<FIELD_SIZE;j++)
		{
			minefield[i][j]= MINE_NOT_PRESENT;
			field_info[i][j]= FIELD_UNMARKED;
		}
	for(k=0;k<FIELD_MINE_NO;k++)
	{
		int seed = random(FIELD_SIZE*FIELD_SIZE);
		i = seed/FIELD_SIZE;
		j = seed%FIELD_SIZE;
		if(minefield[i][j]== MINE_PRESENT)
			k--;
		else
			minefield[i][j]= MINE_PRESENT;
	}
	for(i=0;i<FIELD_SIZE;i++)
	{
		for(j=0;j<FIELD_SIZE;j++)
			printxy(FIELD_CHAR,j+1,i+1);
		cout<<endl;
	}
}

void clear(int current_x,int current_y)
{
	if(current_x<1 || current_x > FIELD_SIZE || current_y<1 || current_y>FIELD_SIZE)
		return;
	int totalmines = 0;
	int upl = 1,upp = 1,upr = 1,right = 1,left = 1,dwnl = 1,down = 1,dwnr = 1;
	if(current_x == 1)
	{
		upl = left = dwnl = 0;
	}

	if(current_y == 1)
	{
		upl = upp = upr = 0;
	}

	if(current_x == FIELD_SIZE)
	{
		upr = right = dwnr = 0;
	}

	if(current_y == FIELD_SIZE)
	{
		dwnl = down = dwnr = 0;
	}
	if(upl)
		totalmines += minefield[current_y-2][current_x-2];
	if(upp)
		totalmines += minefield[current_y-2][current_x-1];
	if(upr)
		totalmines += minefield[current_y-2][current_x];
	if(right)
		totalmines += minefield[current_y-1][current_x];
	if(left)
		totalmines += minefield[current_y-1][current_x-2];
	if(dwnl)
		totalmines += minefield[current_y][current_x-2];
	if(down)
		totalmines += minefield[current_y][current_x-1];
	if(dwnr)
		totalmines += minefield[current_y][current_x];
	if(totalmines==0)
		printxy(ZERO_MINES,current_x,current_y);
	else
		printxy('0'+totalmines,current_x,current_y);
	field_info[current_y-1][current_x-1]=totalmines;
	if(totalmines == 0)
	{
		field_info[current_y-1][current_x-1] = FIELD_CLEARED;
		if(upl && field_info[current_y-2][current_x-2]!= FIELD_CLEARED)
			field_info[current_y-2][current_x-2] = FIELD_QUEUED;
		if(upp && field_info[current_y-2][current_x-1]!= FIELD_CLEARED)
			field_info[current_y-2][current_x-1] = FIELD_QUEUED;
		if(upr && field_info[current_y-2][current_x]!= FIELD_CLEARED)
			field_info[current_y-2][current_x] = FIELD_QUEUED;
		if(right && field_info[current_y-1][current_x]!= FIELD_CLEARED)
			field_info[current_y-1][current_x] = FIELD_QUEUED;
		if(left && field_info[current_y-1][current_x-2]!= FIELD_CLEARED)
			field_info[current_y-1][current_x-2] = FIELD_QUEUED;
		if(dwnl && field_info[current_y][current_x-2]!= FIELD_CLEARED)
			field_info[current_y][current_x-2] = FIELD_QUEUED;
		if(down && field_info[current_y][current_x-1]!= FIELD_CLEARED)
			field_info[current_y][current_x-1] = FIELD_QUEUED;
		if(dwnr && field_info[current_y][current_x]!= FIELD_CLEARED)
			field_info[current_y][current_x] = FIELD_QUEUED;
	}
}
void clrqueue()
{
	int y,x,clear_queue=1;
	while(clear_queue!=0)
	{
		for(y=1;y<=FIELD_SIZE;y++)
			for(x=1;x<=FIELD_SIZE;x++)
				if(field_info[y-1][x-1] == FIELD_QUEUED)
					clear(x,y);
		clear_queue = 0;
		for(y=1;y<=FIELD_SIZE;y++)
			for(x=1;x<=FIELD_SIZE;x++)
				if(field_info[y-1][x-1] == FIELD_QUEUED)
					clear_queue++;
	}
}

void show_all()
{
	int x,y,k;
	for(y=1;y<=FIELD_SIZE;y++)
		for(x=1;x<=FIELD_SIZE;x++)
		{
				if(minefield[y-1][x-1]== MINE_PRESENT)
					printxy(MINE,x,y);
				else
					clear(x,y);
		}
}

int start()
{
	gotoxy(1,1);
	printxy(FIELD_SELECT,1,1);
	int exit = 0,i,j,k;
	int current_x = 1,current_y = 1;
	while(exit != 1)
	{
		char a=getch();
		if(a == 'e')
		{
			exit = 1;
			continue;
		}
		else if(a == 'p')
		{
			show_all();
			getch();
			exit = 1;
			continue;
		}
		else if(a=='w' || a=='s' || a=='d' || a=='a')
		{
			if(field_info[current_y-1][current_x-1]== FIELD_UNMARKED)
				printxy(FIELD_CHAR,current_x,current_y);
			else if(field_info[current_y-1][current_x-1] == FIELD_MARKED)
				printxy(MINE,current_x,current_y);
			else if(field_info[current_y-1][current_x-1] == FIELD_CLEARED)
				printxy(ZERO_MINES,current_x,current_y);
			else
				printxy('0'+field_info[current_y-1][current_x-1],current_x,current_y);
			switch(a)
			{
				case 'w':if(current_y == 1)
							current_y = FIELD_SIZE;
						 else
							current_y--;
						 break;
				case 'a':if(current_x == 1)
							current_x = FIELD_SIZE;
						 else
							current_x--;
						 break;
				case 's':if(current_y == FIELD_SIZE)
							current_y = 1;
						 else
							current_y++;
						 break;
				case 'd':if(current_x == FIELD_SIZE)
							current_x = 1;
						 else
							current_x++;
						 break;
			}
			printxy(FIELD_SELECT,current_x,current_y);
		}
		else if(a=='t')
		{
			if(minefield[current_y-1][current_x-1]==MINE_PRESENT)
				return RESULT_EXPLOSION;
			else if(field_info[current_y-1][current_x-1] == FIELD_UNMARKED)
			{
				clear(current_x,current_y);
				clrqueue();
				printxy(FIELD_SELECT,current_x,current_y);
			}
			int y,x,total = 0;
			for(y=1;y<=FIELD_SIZE;y++)
				for(x=1;x<=FIELD_SIZE;x++)
					if(field_info[y-1][x-1] == FIELD_MARKED || field_info[y-1][x-1] == FIELD_UNMARKED)
						total++;
			if(total == FIELD_MINE_NO)
				return RESULT_WIN;
		}
		else if(a=='m' && field_info[current_y-1][current_x-1] == FIELD_UNMARKED)
		{
			field_info[current_y-1][current_x-1] = FIELD_MARKED;
			printxy(MINE,current_x,current_y);
		}
		else if(a=='m' && field_info[current_y-1][current_x-1] == FIELD_MARKED)
		{
			field_info[current_y-1][current_x-1] = FIELD_UNMARKED;
			printxy(FIELD_CHAR,current_x,current_y);
		}
	}
	return RESULT_EXIT;
}

void welcome()
{
		print_centre(WELCOME,6);
		print_centre(INSTRUCT,8);
		print_centre(INSTRUCT_MOVE,9);
		print_centre(INSTRUCT_CLEAR,10);
		print_centre(INSTRUCT_MINE,11);
		print_centre(INSTRUCT_GIVEUP,12);
		print_centre(CONTINUE,13);
		getch();
		clrscr();
		print_centre(DIFFICULTY,8);
		print_centre(DIFFICULTY_1,10);
		print_centre(DIFFICULTY_2,11);
		print_centre(DIFFICULTY_3,12);
		char t;
		while(1)
		{
			t = getch();
			if(t == '1')
			{
				FIELD_SIZE = 6;
				FIELD_MINE_NO = 9;
				break;
			}
			else if(t == '2')
			{
				FIELD_SIZE = 10;
				FIELD_MINE_NO = 20;
				break;
			}
			else if(t == '3')
			{
				FIELD_SIZE = 20;
				FIELD_MINE_NO = 40;
				break;
			}
		}
		OFFSET_X = (80-FIELD_SIZE)/2;
		OFFSET_Y = 2;
}

int main()
{
	clrscr();
	_setcursortype(_NOCURSOR);
	welcome();
	clrscr();
	initialize();
	int result;
	result = start();
	clrscr();
	if(result == RESULT_EXPLOSION)
		print_centre(MINE_EXPLOSION,3);
	else if(result == RESULT_EXIT)
		print_centre(GAME_EXIT,3);
	else if(result == RESULT_WIN)
		print_centre(GAME_WON,3);
	else
		print_centre(NEVER_TO_BE_PRINTED,3);
	getch();
	_setcursortype(_NORMALCURSOR);
	return 0;
}