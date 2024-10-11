#### The Matrix Alphabet
![[Pasted image 20240724174515.png]]

$$cv + dw = c\begin{bmatrix}1 \cr 1 \cr 0 \cr \end{bmatrix} +d\begin{bmatrix}0 \cr 1 \cr 1 \cr\end{bmatrix} = \begin{bmatrix}c\cr c+ d \cr d \cr \end{bmatrix}$$
![[Pasted image 20240724174327.png]]

#### Dot Product
$$v \cdot w = v_1 w_1 + v_2 w_2$$
$$
\begin{bmatrix}
v_1 \cr
v_2 \cr
v_3
\end{bmatrix}
\cdot
\begin{bmatrix}
w_1 \cr
w_2 \cr
w_3
\end{bmatrix}
= v_1w_1 + v_2w_2 + v_3w_3
$$
Length
- ![[Pasted image 20240724172701.png]]
- ![[Pasted image 20240724172612.png]]
$$
||v||^2 = \begin{bmatrix}1\cr 2\cr 3\cr\end{bmatrix} \cdot \begin{bmatrix}1\cr 2\cr 3\cr\end{bmatrix} = 1+4+9=14
$$$$
length =  ||v|| = \sqrt{v \cdot v}
$$
$$
v \cdot v = v_1^2 + v_2^2 + ... + v_n^2
$$
```
A unit vector u is a vector whose length equals one.
```
$$
u \cdot u = 1
$$
```
Right Angles
```
The dot product is $v \cdot w = 0$ when $v$ is perpendicular to $w$ 

```
*Perpendicular Vectors*
```
$$
||v||^2 + ||w||^2 = ||v - w||^2
$$
```
Pythagoras
```
$$(v_1^2 + v_2^2) + (w_1^2 + w_2^2) = (v_1 - w_1)^2 + (v_2 - 2_2)^2$$
*The angle is above 90 when $v \cdot w$ is negative and is positive when angle is less than 90*
$$
u \cdot U = \cos(\theta), when |u \cdot U| \leq 1
$$
```
Cosine Formula: If v and w are nonzero vectors then
```
$$
\frac{v \cdot w}{||v|| ||w||} = \cos(\theta)
$$
```
Schwarz Inequality:
```
$$
|v \cdot w| \leq ||v|| ||w|| 
$$
```
Triangle Inequality
```
$$
||v + w|| \leq ||v|| + ||w||
$$
$$
\cos(\theta) = \frac{v \cdot w}{||v|| ||w||} = \frac{4}{\sqrt{5}\sqrt{5}} = \frac{4}{5}
$$
$$
v \cdot w = \begin{bmatrix}1 \cr 2 \end{bmatrix} \cdot \begin{bmatrix}3 \cr 4 \end{bmatrix}, \begin{bmatrix} 1&2 \end{bmatrix}  \begin{bmatrix}3 \cr 4 \end{bmatrix} = v^` * w
$$
----
1.3 Matrices
$$
\begin{bmatrix}1 & 2 \cr 3 & 4  \cr 5 & 6 \end{bmatrix} \begin{bmatrix}7 \cr 8 \end{bmatrix} = \begin{bmatrix}1 \cdot7 + 2 \cdot8 \cr 3 \cdot7 + 4 \cdot8 \cr 5 \cdot 7 + 6 \cdot 8\end{bmatrix} = \begin{bmatrix}23\cr53\cr83\end{bmatrix}
$$
$$
\begin{bmatrix}
2&5\cr3&7
\end{bmatrix}
\begin{bmatrix}
x_1 \cr x_2
\end{bmatrix}
= 
\begin{bmatrix}
b_1 \cr b_2
\end{bmatrix}
replaces 
2x_1+5x_2= b_1,
3x_1 + 7x_2 = b_2
$$

```
Matrix times vector Combination of columns
```
$$
Ax = \begin{bmatrix}
1 & 0 & 0 \cr
-1 & 1 & 0 \cr
0 & -1 & 1
\end{bmatrix}
\begin{bmatrix}
x_1 \cr
x_2 \cr
x_3
\end{bmatrix}
=
\begin{bmatrix}
x_1 \cr
x_2 - x_1 \cr
x_3 - x_2 
\end{bmatrix}
=
\begin{bmatrix}
b_1 \cr
b_2 \cr
b_3
\end{bmatrix}
= b
$$
$$
Ax = \begin{bmatrix}
1 & 0 & 0 \cr
-1 & 1 & 0 \cr
0 & -1 & 1
\end{bmatrix}
\begin{bmatrix}
x_1 \cr
x_2 \cr
x_3
\end{bmatrix}
=
\begin{bmatrix}
(1,0,0) \cdot (x_1, x_2, x_3) \cr
(-1,1,0) \cdot (x_1, x_2, x_3) \cr
(0,-1,1) \cdot (x_1, x_2, x_3) \cr
\end{bmatrix}

$$
#### $ax = b, x = a^{-1} b$
```
The Inverse Matrix
```
$$
\begin{bmatrix}
x_1 \cr
x_2 \cr
x_3 
\end{bmatrix}
=
\begin{bmatrix}
b_1 \cr
b_1 & b_2 \cr
b_1 & b_2 & b_3 
\end{bmatrix}
= 
\begin{bmatrix}
1 & 0 & 0 \cr
1 & 1 & 0 \cr
1 & 1 & 1 
\end{bmatrix}
\begin{bmatrix}
b_1 \cr
b_2 \cr
b_3 
\end{bmatrix}
$$
```
Cyclic Differences
```
$$
Cx = 
\begin{bmatrix}
1 & 0 & -1 \cr
-1 & 1 & 0 \cr
0 & -1 & 1 
\end{bmatrix}
\begin{bmatrix}
x_1 \cr
x_2 \cr
x_3 
\end{bmatrix}
=
\begin{bmatrix}
x_1 - x_3 \cr
x_2 - x_1 \cr
x_3 - x_2
\end{bmatrix}
= b
$$
-----
2.1 Vectors and Linear Equations
four steps to understanding elimination using matrices.
1. Elimination goes from A to a triangular U by a sequence of matrix steps Eij .
2. The triangular system is solved by back substitution: working bottom to top.
3. In matrix language A is factored into LU = (lower triangular) (upper triangular).
4. Elimination succeeds if A is invertible. (But it may need row exchanges.)

Identity Matrix
$$
\begin{bmatrix}
1 & 0 & 0 \cr
0 & 1 & 0 \cr
0 & 0 & 1
\end{bmatrix}
$$
----
2.3

#### Elimination Matrix

$$
\begin{bmatrix}
1 & 0 & 0 \cr
-2 & 1 & 0 \cr
0 & 0 & 1 
\end{bmatrix}
$$
#### Permutation (row exchange) Matrix
$$
\begin{bmatrix}
0 & 0 & 1 \cr
0 & 1 & 0 \cr
1 & 0 & 0 
\end{bmatrix}
$$

#### Augmentation Matrix
$$
\begin{bmatrix}
2 & 4 & -2 & 2 \cr
4 & 9 & -3 & 8 \cr
-2 & -3 & 7 & 10 
\end{bmatrix}
$$

