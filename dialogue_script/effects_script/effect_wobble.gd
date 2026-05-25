extends "res://dialogue_script/effects_script/effect_data.gd"
class_name WobbleEffect

## 单轮最大旋转角度
@export_range(0.1, 720.0, 0.5) var rotation: float = 5.0
## 摇晃次数，和decay并用的时候有冲突，写的时候所以往大了写，比如我想摇晃10次，衰减系数是0.3，就写18或者20.反正你能懂我意思！
@export_range(1, 100, 1) var count: int = 3
## 越小越快
@export_range(0.01, 100.0, 0.01) var speed: float = 0.3
## 衰减值，0=没惯性，1=纯机械等幅。超过1幅度越来越大会像螺旋桨。但是吧这块是在不好写。因为这是衰减算的，所以count往大一倍的方向去写，因为衰减到后面会这个值会越来越小，几乎不可见
@export_range(0.0, 1.0, 0.01) var decay: float = 0.5
## 当前幅度小于此值直接截断，避免微可见的抽搐。按死了几乎不可见的tween动画
@export_range(0.0, 5.0, 0.05) var snap_threshold: float = 0.5
