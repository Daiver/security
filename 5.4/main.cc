#include <stdio.h>
#include <assert.h>
#include "jpeglib.h"
#include "jpegint.h"
#include <stdlib.h>
//#include "tanssup.h"
#include <setjmp.h>
#include <fstream>


void extract_dc(j_decompress_ptr cinfo, jvirt_barray_ptr *coeffs, const char *outfname)
{
    int ci = 0;
    std::ofstream out(outfname);
    jpeg_component_info *ci_ptr = &cinfo->comp_info[ci];

    JQUANT_TBL *tbl = ci_ptr->quant_table;
    UINT16 dc_quant = tbl->quantval[0];

    //printf("%d %d\nraw DC coefficients:\n", ci_ptr->height_in_blocks, ci_ptr->width_in_blocks);

    JBLOCKARRAY buf =
    (cinfo->mem->access_virt_barray)
    (
        (j_common_ptr)cinfo,
        coeffs[ci],
        0,
        ci_ptr->v_samp_factor,
        FALSE
    );
    for (int sf = 0; (JDIMENSION)sf < ci_ptr->height_in_blocks; ++sf)
    {
        for (JDIMENSION b = 0; b < ci_ptr->width_in_blocks; ++b)
        {
            for(int dd = 0; dd < 63; dd++){
                out << buf[sf][b][dd] << " ";
                //printf("% 2d ", buf[sf][b][dd]);                        
            }
            out << "\n";
            //printf("\n");
            //printf("\n");
        }
        //printf("\n");
    }
    out.close();
}


int read_jpeg_file( char *filename, const char *outfname)
{
	/* these are standard libjpeg structures for reading(decompression) */
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;
	/* libjpeg data structure for storing one row, that is, scanline of an image */
	JSAMPROW row_pointer[1];
	
	FILE *infile = fopen( filename, "rb" );
	unsigned long location = 0;
	int i = 0;
	if ( !infile )
	{
		printf("Error opening jpeg file %s\n!", filename );
		return -1;
	}
	cinfo.err = jpeg_std_error( &jerr );
	jpeg_create_decompress( &cinfo );
	jpeg_stdio_src( &cinfo, infile );
	jpeg_read_header( &cinfo, TRUE );
    jvirt_barray_ptr *ptr =  jpeg_read_coefficients(&cinfo);

    extract_dc(&cinfo, ptr, outfname );

	jpeg_destroy_decompress( &cinfo );
	fclose( infile );
    printf("END of read\n");
	return 0;
}

int main()
{
	//char *infilename = "test.jpg";
	char *infilename = "/home/daiver/sec_images/images_jpg/image_007.jpg";
    const char *outfname = "dump_007.txt";
	/* Try opening a jpeg*/
	read_jpeg_file( infilename, outfname ) ;
	return 0;
}


