void I2C3_init (void);
static int wait_until_done (void);
char I2C3_write_onebyte (int slave_address, char slave_memory_address, char* data);
char I2C3_read_onebyte(int slave_address, char slave_memory_address, char* data);
unsigned int CalculateLux(unsigned int iGain, unsigned int tInt, unsigned int ch0, unsigned int ch1, int iType);