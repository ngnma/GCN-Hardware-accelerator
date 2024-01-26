import numpy as np

def generate_a(n1,n2,density=0.005):
    
    total_elements = n1 * n2

    # Calculate the number of non-zero elements needed for the desired density
    non_zero_elements = int(total_elements * density)

    # Generate a random matrix with values between 0 and 10
    np.random.seed(1235)
    a = np.random.randint(0, 11, size=(n1, n2))

    # Create an array of all indices in the matrix
    all_indices = np.arange(total_elements)

    # Randomly shuffle the indices
    np.random.shuffle(all_indices)

    # Set a certain number of elements to zero to achieve the desired density
    a.ravel()[all_indices[:total_elements - non_zero_elements]] = 0

    non_zero_indices = np.argwhere(a)
    values = a[non_zero_indices[:, 0], non_zero_indices[:, 1]]

    rows = non_zero_indices[:, 0]
    columns = non_zero_indices[:, 1]

    return a,rows,columns,values 

def generate_x(n1,n2):
    np.random.seed(1234)
    x = np.random.randint(10,100,size=(16,8))
    return x

def generate_w(n1,n2):
    np.random.seed(123)
    w = np.random.randint(10,100,size=(8,12))
    return w

def calculate_ax(a,x):
    return a@x

def calculate_axw(ax,w):
    return ax@w
    

