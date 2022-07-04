#!/usr/bin/env bash

function manual(){
	cat << EOF
        提示：该脚本为图片批处理，需安装imagemagick。
	[Help] -h                  查询帮助(help）信息。
 
               -c num             对jpeg格式图片进行图片质量压缩（compression),num取值为0%-100%。

	       -r num             对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率（resolution)，num取值为0%-100%。

	       -w font_size text   对图片批量添加自定义文本水印(watermark),font_size为字体大小，text为嵌入水印文本内容。

	       -p text             统一添加文件名前缀（prefix)，text为前缀文本。

	       -s text             统一添加文件名后缀（suffix），text为后缀文本。

               -f                  将png/svg图片统一转换为jpg格式。

EOF
}

#对jpeg格式图片进行图片质量压缩。

function compress {
	    num="$1"
	        i=0
		    for image in *;do
			            type=${image##*.}
				            if [[ "${type}" != "jpg" ]];then 
						                continue
								        else
										            i=$((i+1))
											                convert "${image}" -quality "${num}" "${image}" 2>/dev/null
													            echo "${image}压缩完成"
														            fi
															        done
																    if [ $i -eq 0 ];then
																	           echo "当前目录无jpe文件"
																		       fi
																	       }

#在保持原始宽高比的前提下对jpeg/png/svg格式图片压缩分辨率

function resolution {
	    num="$1"
	        i=0
		    for image in *;do
			            type=${image##*.}
				            if [[ "${type}" == "jpg" || "${type}" == "png" || "${type}" == "svg" ]];then
					                convert -resize "${num}x${num}" "${image}" "${image}"
								            echo "${image}分辨率修改完成"
									                i=$((i+1))
											        fi
												    done
												        if [ $i -eq 0 ];then
														       echo "当前目录下无jpg/png/svg图像文件"
														           fi
															       
														   }


#对图像批量添加自定义水印。

function watermark {
	    font_size="$1"
	        text="$2"
		    i=0
		        for image in *;do
				        type=${image##*.}
					        if [[ "${type}" == "jpg" || "${type}" == "png" || "${type}" == "svg" ]];then
							            convert "${image}" -pointsize "${font_size}" -fill cyan -gravity southeast -draw "text 50 50 ${text}" "${image}" 2>/dev/null
								              echo "${image}已添加字体大小为${font_size}的水印${text}"
									                i=$((i+1))
											        fi
												    done
												        if [ $i -eq 0 ];then
														       echo "当前目录下无jpg/png/svg图像文件"
														           fi
														   }


#为当前图像批量添加前缀。

function prefix {
	    text="$1"
	        i=0
		    for image in *;do
			            type=${image##*.}
				            if [[ "${type}" == "jpg" || "${type}" == "png" || "${type}" == "svg" ]];then
						              mv "${image}" "$1""${image}" 2>/dev/null
							                i=$((i+1))
									          echo "${image}已添加文件名前缀${text}"
										          fi
											      done
											          if [[ $i -eq 0 ]];then
													         echo "当前目录下无jpg/png/svg图像文件"
														     fi
													     }


#为当前图像批量添加后缀。

function suffix {
	    text="$1"
	        i=0
		    for image in *;do
			            type=${image##*.}
				            if [[ "${type}" == "jpg" || "${type}" == "png" || "${type}" == "svg" ]];then
						                mv "${image}" "${image%.*}$1"".${type}" 2>/dev/null
								            echo "${image}已添加文件名后缀${text}"
									                i=$((i+1))
											        fi
												    done
												        if [[ $i -eq 0 ]];then
														       echo "当前目录下无jpg/png/svg图像文件"
														           fi
														   }


#将文件夹中的png/svg格式图像批量转换为jpg格式图像

function format {
	    i=0
	        for image in *;do
			        type=${image##*.}
				        if [[ "${type}" == "png" || "${type}" == "svg" ]];then
						            convert "${image}" "${image%.*}.jpg" 2>/dev/null
							                echo "${image}已转换为jpg格式,源文件未删除"
									            i=$((i+1))
										            fi
											        done
												    if [[ $i -eq 0 ]];then
													           echo "当前目录下无png/svg图像文件"
														       fi
													       }

case "$1" in
	    "")
		            echo "未选择操作,试试-h或者--help"
			            ;;
				        "-h"|"--help")
						        manual
							        ;;
								    "-c"|"--compress")
									            if [[ "$2" == "" ]];then
											                echo "缺少参数,请参考帮助信息"
													        else
															            compress "$2"
																            fi
																	            ;;
																		        "-r"|"--resolution")
																				        if [[ "$2" == "" ]];then
																						            echo "缺少参数,请参考帮助信息"
																							            else
																									                resolution "$2"
																											        fi
																												        ;;
																													    "-w"|"--watermark")
																														            if [[ "$2" == "" || "$3" == "" ]];then
																																                echo "缺少参数,请参考帮助信息"
																																		        else
																																				            watermark "$2" "$3"
																																					            fi
																																						            ;;
																																							        "-p"|"--prefix")
																																									        if [[ "$2" == "" ]];then
																																											            echo "缺少参数,请参考帮助信息"
																																												            else
																																														                prefix "$2"
																																																        fi
																																																	        ;;
																																																		    "-s"|"--suffix")
																																																			            if [[ "$2" == "" ]];then
																																																					                echo "缺少参数,请参考帮助信息"
																																																							        else
																																																									            suffix "$2"
																																																										            fi
																																																											            ;;
																																																												        "-f"|"--format")
																																																														        format
																																																															        ;;
																																																														esac

