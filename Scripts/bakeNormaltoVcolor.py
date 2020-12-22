import bpy

current_obj = bpy.context.active_object 
mesh = current_obj.data

if mesh.vertex_colors:
    vcol_layer = mesh.vertex_colors.active
else:
    vcol_layer = mesh.vertex_colors.new()

print("*"*40)

for poly in mesh.polygons:
        for loop_index in poly.loop_indices:
            loop_vert_index = mesh.loops[loop_index].vertex_index

            #color = [1 , 0, 0]

            #vcol_layer.data[loop_index].color = color

            #vcol_layer.data[loop_index].color = mesh.vertices[loop_vert_index].normal
            color = mesh.vertices[loop_vert_index].normal
            vcol_layer.data[loop_vert_index].color = color

            print("painting vert",loop_index, "to color ", color[0], color[1], color[2])


mesh.vertex_colors.active = vcol_layer


mesh.update()