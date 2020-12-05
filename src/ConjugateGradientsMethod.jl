using Printf
using SparseArrays
using LinearAlgebra
# using MatrixMarket

# -----------------------------------------------
#
# Реализация алгоритма решения СЛАУ методом сопряжённых градиентов.
#
# Матрица должна быть симметричной положительно определённой.
#
# -----------------------------------------------

# Требуемая точность
const eps = 0.001

# Вывод процесса в stdout
const debug = false
# Вывод входных данных
const info = false

# Чтение разреженного вектора из файла
function read_csc_vector(filename)
  file = open(filename, "r")
  colptr = parse.(Int, split(readline(file)))
  nzval = parse.(Float64, split(readline(file)))
  close(file)
  return sparsevec(colptr, nzval)
end

# Чтение разреженной матрицы из файла
function read_csc_matrix(filename)
  file = open(filename, "r")
  colptr = parse.(Int, split(readline(file)))
  rowval = parse.(Int, split(readline(file)))
  nzval = parse.(Float64, split(readline(file)))
  close(file)
  return sparse(colptr, rowval, nzval)
end

function read_mtx_matrix(filename)
  return MatrixMarket.mmread(filename, true)
end

# Вывод полученного вектора
function print_vector(vector, mask, eps)
  for i in vector_x[:]
    @printf(" %.5f ", (abs(i) < eps ? 0 : i))
  end
end

matrix_A = read_csc_matrix("resources/little_matrix.csc")
vector_b = read_csc_vector("resources/little_vector.csc")

vector_x = Array{Float64,1}(zeros(length(vector_b))) .+ 0.2
vector_r = vector_b - (matrix_A * vector_x)
vector_z = vector_r

if (info) 
  println("vector_b: ", vector_b)
  println("matrix_A: ", matrix_A)
  println("vector_x0: ", vector_x)
  println("vector_r0: ", vector_r)
  println("vector_z0: ", vector_z)
end

i = 1
while (eps < (norm(vector_r) / norm(vector_b)) || i <= length(vector_b))
  local vector_xp = vector_x
  local vector_rp = vector_r
  local vector_zp = vector_z
  alpha = (transpose(vector_rp) * vector_rp) / (transpose(matrix_A * vector_zp) * vector_zp)
  if (debug) println("alpha[", i, "]: ", alpha) end
  global vector_x = vector_xp + alpha * vector_zp
  if (debug) println("vector_x[", i, "]: ", vector_x) end
  global vector_r = vector_rp - alpha * (matrix_A * vector_zp)
  if (debug) println("vector_r[", i, "]: ", vector_r) end
  if (debug) println("vector_rm[", i, "]: ", vector_rp) end
  beta = (transpose(vector_r) * vector_r) / (transpose(vector_rp) * vector_rp)
  if (debug) println("beta[", i, "]: ", beta) end
  global vector_z = vector_r + beta * vector_zp
  if (debug) println("vector_z[", i, "]: ", vector_z) end
  if (debug) println() end
  global i += 1
end

print("x: ")
print_vector(vector_x, "%.3f", eps)

println(read_csc_matrix("resources/bcsstk16.csc"))
