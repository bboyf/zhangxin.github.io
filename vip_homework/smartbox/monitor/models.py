from django.db import models

from uuid import uuid4

def gen_uuid():
    return uuid4().hex

class Camera(models.Model):
    uid=models.CharField(max_length=32,verbose_name='uuid',editable=False,default=gen_uuid)
    name=models.CharField(max_length=50,verbose_name='摄像机名称',default='')
    rtsp=models.CharField(max_length=150,verbose_name='rtsp',default='')
    position=models.CharField(max_length=255,verbose_name='位置',default='',blank=True)
    create_time=models.DateTimeField(verbose_name='添加时间',editable=False,auto_now=True)
    is_active=models.IntegerField(verbose_name='状态',choices=((0,'offline'),(1,'online')),default=0)
    def __str__(self) -> str:
        return self.name
    
    class Meta:
        db_table='tb_camera'
        ordering = ('-create_time',)
