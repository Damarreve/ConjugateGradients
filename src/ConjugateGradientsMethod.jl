using SparseArrays
using LinearAlgebra

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

matrix_A = read_csc_matrix("resources/little_matrix.csc")
vector_b = read_csc_vector("resources/little_vector.csc")

vector_x = Array{Float64,1}(zeros(length(vector_b))) .+ 0.2
vector_r = vector_b - (matrix_A * vector_x)
vector_z = vector_r

println("vector_b: ", vector_b)
println("matrix_A: ", matrix_A)
println("vector_x0: ", vector_x)
println("vector_r0: ", vector_r)
println("vector_z0: ", vector_z)

eps = 0.1
println(norm(vector_r) / norm(vector_b))
println(eps)
i = 1
# TODO: Очень кривой алгоритм, не работает!
while eps < (norm(vector_r) / norm(vector_b))
  local vector_xp = vector_x
  local vector_rp = vector_r
  local vector_zp = vector_z
  alpha = (transpose(vector_rp) * vector_rp) / (transpose(matrix_A * vector_zp) * vector_zp)
  println("alpha[", i, "]: ", alpha)
  global vector_x = vector_xp + alpha * vector_zp
  println("vector_x[", i, "]: ", vector_x)
  global vector_r = vector_rp - alpha * (matrix_A * vector_zp)
  println("vector_r[", i, "]: ", vector_r)
  println("vector_rm[", i, "]: ", vector_rp)
  beta = (transpose(vector_r) * vector_r) / (transpose(vector_rp) * vector_rp)
  println("beta[", i, "]: ", beta)
  global vector_z = vector_r + beta * vector_zp
  println("vector_z[", i, "]: ", vector_z)
  println()
  global i += 1
end
