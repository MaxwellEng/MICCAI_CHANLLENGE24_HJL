import numpy as np
from scipy.ndimage import binary_fill_holes
from skimage import measure
# Hello! crop_to_nonzero is the function you are looking for. Ignore the rest.
from acvl_utils.cropping_and_padding.bounding_boxes import get_bbox_from_mask, crop_to_bbox, bounding_box_to_slice

def largestConnectComponent(arr):
    label_image, num = measure.label(arr, background=0, return_num=True)
    areas = [r.area for r in measure.regionprops(label_image)]
    areas.sort()
    
    if num > 1:
        for region in measure.regionprops(label_image):
            if (region.area < areas[-1]):
                for coordinates in region.coords:
                    label_image[coordinates[0], coordinates[1], coordinates[2]] = False
    return label_image

def create_nonzero_mask(data, ref_img=None):
    """

    :param data:
    :return: the mask is True where the data is nonzero
    """
    assert data.ndim in (3, 4), "data must have shape (C, X, Y, Z) or shape (C, X, Y)"
    nonzero_mask = np.zeros(data.shape[1:], dtype=bool)
    if ref_img is not None:
        nonzero_mask = ref_img != 0
    else:
        for c in range(data.shape[0]):
            this_mask = (data[c]>-150) & (data[c]<600)
            nonzero_mask = nonzero_mask | this_mask
        label_image = largestConnectComponent(nonzero_mask)
        nonzero_mask=label_image
    return binary_fill_holes(nonzero_mask)

def expand_bbox3d(bbox, data_shape):  
    z1= bbox[0][0]  
    z2= bbox[0][1]
    y1= bbox[1][0]  
    y2= bbox[1][1]
    x1= bbox[2][0]  
    x2= bbox[2][1]
    z_max=data_shape[0]-1
    y_max=data_shape[1]-1
    x_max=data_shape[2]-1  
    new_x1 = max(x1 - 30, 0)  
    new_y1 = max(y1 - 15, 0)  
    new_z1 = max(z1 - 40, 0)  
    new_x2 = min(x2 + 30, x_max)  
    new_y2 = min(y2 + 15, y_max)  
    new_z2 = min(z2 + 25, z_max)  
    return [[int(new_z1), int(new_z2)], [int(new_y1), int(new_y2)], [int(new_x1), int(new_x2)]]  

def shrink_bbox3d(bbox, data_shape):  
    z1= bbox[0][0]  
    z2= bbox[0][1]
    y1= bbox[1][0]  
    y2= bbox[1][1]
    x1= bbox[2][0]  
    x2= bbox[2][1] 
    new_x1 = x1 + 15
    new_y1 = y1 + 10
    new_x2 = x2 - 15 
    new_y2 = y2 - 10
    return [[int(z1), int(z2)], [int(new_y1), int(new_y2)], [int(new_x1), int(new_x2)]]  


#hjl
def crop_to_nonzero(data, seg=None, ref_img=None, nonzero_label=-1):
    """

    :param data:
    :param seg:
    :param nonzero_label: this will be written into the segmentation map
    :return:
    """
    nonzero_mask = create_nonzero_mask(data, ref_img)
    bbox = get_bbox_from_mask(nonzero_mask)
    if ref_img is not None:
        data_shape=data.shape[1:]
        #print('bbox:',bbox)
        bbox = expand_bbox3d(bbox, data_shape)
    else:
        bbox = shrink_bbox3d(bbox, data.shape[1:])
    slicer = bounding_box_to_slice(bbox)
    nonzero_mask = nonzero_mask[slicer][None]
    
    slicer = (slice(None), ) + slicer
    data = data[slicer]
    if seg is not None:
        seg = seg[slicer]
        seg[(seg == 0) & (~nonzero_mask)] = nonzero_label
    else:
        seg = np.where(nonzero_mask, np.int8(0), np.int8(nonzero_label))
    return data, seg, bbox


