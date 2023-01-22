#include <stdio.h>
#include "TM4C123GH6PM.h"
#include "i2c_lux_funcs.h"
#include "led_logic.h"
#include "other_funcs.h"

//
extern void OutStr(char *);
//
extern void gpio_ssi_init(void);
extern void first_config_Nokia(void);
extern void LCD_Comments(void);

int lux0mean = 0;
int lux1mean = 0;
int lux = 0;


int main (void)
{
	int i = 256;
	int temp0 = 0;
	int temp1 = 0;
	char str[256];
	char datalow[1];
	char datahigh[1];
	char pwr [1] = {0x03}; // Power up the device
	char integ [1] = {0x00}; // 13.7ms conversion rate, may be omitted
	
	I2C3_init();
	adc_gpio_init();
	adc_init();
	push_buttons_init();
	pwm_init();
	gpio_ssi_init();
	first_config_Nokia();
	Screen_Clear();
	initial_screen();
	led_gpio_init();

	I2C3_write_onebyte(0x39, 0x80, pwr);
	I2C3_write_onebyte(0x39, 0x81, integ);
	timer1_delay();
	
while (1)
{
	
	I2C3_read_onebyte(0x39, 0x8C, datalow);
	I2C3_read_onebyte(0x39, 0x8D , datahigh);
	temp0 += (datahigh[0] << 8) + datalow[0];
	
	//timer1_delay();
	
	I2C3_read_onebyte(0x39, 0x8E , datalow);
	I2C3_read_onebyte(0x39, 0x8F , datahigh);
	temp1 += (datahigh[0] << 8) + datalow[0];

	i--;
	adjust();
	
	if (i == 0)
	{
		
		lux0mean = temp0 / 256;
		lux1mean = temp1 / 256;
		lux = CalculateLux(0, 0, lux0mean, lux1mean, 0);
		sprintf(str,"Lower threshold: %d \nUpper threshold: %d \nLuminosity: %d lux\n\n\4",getlowth(),gethighth(),lux);
		OutStr(str);
		step_1();
		digit(getlowth());
		step_2();
		digit(gethighth());
		step_3();
		digit(lux);
		step_4();
		led_rgb(lux);
		duty_cycle(lux);
		i = 256;
		temp0 = 0;
		temp1 = 0;
		
	}
}

}

