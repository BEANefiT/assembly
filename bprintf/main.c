void	bprintf (char* msg, ...);

int main()
{
	char*	str = "Здарова";
	char	c = 'l';
	unsigned long long	a = 0xeda;

	bprintf ("%x\n%x\n%x\n%x\n%x\n%x\n%x\n%x\n\0", a, a, a, a, a, a, a, a);
	
	return 0;
}
