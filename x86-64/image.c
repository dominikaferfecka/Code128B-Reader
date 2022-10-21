#include "image.h"
#include "tab.h"
#include <stdio.h>
#include <stdlib.h>


ImageInfo* readBmp(const char* fileName)
{
    FILE* file = fopen(fileName,"rb");
    if(file == NULL)
    {
        return NULL;
    }
    RGBbmpHdr btmhdr;
	
    if (fread((void*) &btmhdr, sizeof(btmhdr), 1, file) != 1)
    {
        fclose(file);
        return NULL;
    }
	
    if (btmhdr.bfType != 0x4D42 ||
        //btmhdr.biPlanes != 3 ||
		btmhdr.biPlanes != 1 ||
        btmhdr.biBitCount != 24 ||
        btmhdr.biCompression != 0)
    {
        printf("Invalid bitmap header.\n");
        fclose(file);
        return NULL;
    }

    ImageInfo* imginfo = (ImageInfo *) malloc(sizeof(ImageInfo));
    if (imginfo == NULL)
    {
        fclose(file);
        return NULL;
    }
	
    imginfo->pImg = NULL;
    imginfo->height = abs(btmhdr.biHeight);
    imginfo->width = btmhdr.biWidth;
    imginfo->line_bytes = imginfo->width * 3;
    if (imginfo->line_bytes % 4 != 0)
        imginfo->line_bytes += 4 - (imginfo->line_bytes % 4);

    if (fseek(file, btmhdr.bfOffBits, SEEK_SET) != 0)
    {
        fclose(file);
        freeImage(imginfo);
        return NULL;
    }
    imginfo->pImg = (unsigned char*) malloc(btmhdr.biSizeImage);
    if(imginfo->pImg == 0)
    {
        fclose(file);
        freeImage(imginfo);
        return NULL;
    }
    if (fread(imginfo->pImg, 1, btmhdr.biSizeImage, file) != btmhdr.biSizeImage)
    {
        fclose(file);
        freeImage(imginfo);
        return NULL;
    }
    fclose(file);
	/*for (int i = 0; i < 18000; ++i)
	{
		printf("%#08x ", *((imginfo->pImg)+4320+i));
	}
	printf("here      > %d\n");*/
    return imginfo;
}


void freeImage(ImageInfo *imageinfo)
{
    if (imageinfo != NULL)
    {
        if(imageinfo->pImg != NULL)
            free(imageinfo->pImg);
        free(imageinfo);
    }
}
	

int decode128(unsigned char *source_bitmap, int16_t* tabCode, unsigned char *result_text); 


int main(int argc, char* argv[])
{
	ImageInfo* pInfo;
	
	pInfo = readBmp("1.bmp");
	
	//int16_t tabCode[] = {1740, 1644, 1638, 1176, 1164, 1100, 1224, 1220, 1124, 1608, 1604, 1572, 1436, 1244, 1230, 1484, 1260, 1254, 1650, 1628, 1614, 1764, 1652, 1902, 1868, 1836, 1830, 1892, 1844, 1842, 1752, 1734, 1590, 1304, 1112, 1094, 1416, 1128, 1122, 1672, 1576, 1570, 1464, 1422, 1134, 1496, 1478, 1142, 1910, 1678, 1582, 1768, 1762, 1774, 1880, 1862, 1814, 1896, 1890, 1818, 1818, 1914, 1602, 1930, 1328, 1292, 1200, 1158, 1068, 1062, 1424, 1412};
	//int16_t tabCode[] = {0x6cc, 0x66c, 0x666, 0x498, 0x48c, 0x44c, 0x4c8, 0x4c4, 0x464, 0x648, 0x644, 0x624, 0x59c, 0x4dc, 0x4ce, 0x5cc, 0x4ec, 0x4e6, 0x672, 0x65c, 0x64e, 0x6e4, 0x674, 0x76e, 0x74c, 0x72c, 0x726, 0x764, 0x734, 0x732, 0x6d8, 0x6c6, 0x636, 0x518, 0x458, 0x446, 0x588, 0x468, 0x462, 0x688, 0x628, 0x622, 0x5b8, 0x58e, 0x46e, 0x5d8, 0x5c6, 0x476, 0x776, 0x68e, 0x62e, 0x6e8, 0x6e2, 0x6ee, 0x758, 0x746, 0x716, 0x768, 0x762, 0x71a, 0x71a, 0x77a, 0x642, 0x78a, 0x530, 0x50c, 0x4b0, 0x486, 0x42c, 0x426, 0x590, 0x584};
	//stworz tablice bajtów danej lini
	unsigned char tabBMP[600];
	int iterator = 0;
	for (int i = 0; i < 1800; i+=3)
	{
		tabBMP[iterator] = *((pInfo->pImg)+i+43200);
		iterator++;
	}
	
	
	/*for (int i = 0; i < 1800; ++i)
	{
		printf("%#08x ", *((pInfo->pImg)+i+43200));
	}
	*/
	printf("here      > %d\n");
	
	
	unsigned char memoryOut[12];
	//unsigned char* memoryOut;
	decode128(tabBMP, tabCode, memoryOut);

	for (int i = 0; i < 12; ++i)
	{
		char result = (char)(memoryOut[i]+31);
		if (result == 32)
		{
		   printf(" ERROR - invalid check sum ");
		}
		else if (result != ' ')
		{
			printf(" %c", result);
		}
	}
	//printf("here      > %c\n", (char)(memoryOut[0]+31));
	
	return 0;
}

