#include "image.h"
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
	
	int16_t tabCode[] = {1740, 1644, 1638, 1176, 1164, 1100, 1224, 1220, 1124, 1608, 1604, 1572, 1436, 1244, 1230, 1484, 1260, 1254, 1650, 1628, 1614, 1764, 1652, 1902, 1868, 1836, 1830, 1892, 1844, 1842, 1752, 1734, 1590, 1304, 1112, 1094, 1416, 1128, 1122, 1672, 1576, 1570, 1464, 1422, 1134, 1496, 1478, 1142, 1910, 1678, 1582, 1768, 1762, 1774, 1880, 1862, 1814, 1896, 1890, 1818, 1818, 1914, 1602, 1930, 1328, 1292, 1200, 1158, 1068, 1062, 1424, 1412};
	
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
		if (result != ' ')
		{
			printf(" %c", result);
		}
	}
	//printf("here      > %c\n", (char)(memoryOut[0]+31));
	
	return 0;
}

