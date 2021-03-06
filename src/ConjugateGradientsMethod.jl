using Dates
using SparseArrays
using LinearAlgebra

# -----------------------------------------------
#
# Реализация алгоритма решения СЛАУ методом сопряжённых градиентов.
#
# Матрица должна быть симметричной положительно определённой.
#
# -----------------------------------------------

# Требуемая точность
const eps = 1e-6

# Вывод процесса в stdout
const debug = false
# Вывод входных данных
const info = false
# Вывод итераций
const process = false

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

# Скалярное произведение векторов
function s_multiply(_vector1, _vector2)
  result = Threads.Atomic{Float64}(0.0)
  mlen = min(length(_vector1), length(_vector2))
  range = div(mlen, Threads.nthreads())
  Threads.@threads for i = 1:range:mlen
    Threads.atomic_add!(result, dot(view(_vector1, i:min(i + range, mlen)), view(_vector2, i:min(i + range, mlen))))
  end
  return result[]
end

# Умножение матрицы на вектор
function mv_multiply(_matrix, _vector)
  result = zeros(size(_matrix, 1))
  Threads.@threads for i = 1:length(result)
    result[i] = dot(_matrix[i, :], _vector)
  end
  return result
end

# Вывод полученного вектора
function print_vector(vector)
  print("[")
  for i in vector[:]
    print(" ", (abs(i) < eps ? 0 : i))
  end
  println("]")
end

# Проверка матрицы на симметричность
function is_matrix_symmetric(matrix)
  for i in 1:size(matrix, 1)
    for j in i+1:size(matrix, 1)
      if (matrix[i, j] != matrix[j, i])
        return false
      end
    end
  end
  return true
end

# Превращение несимметричной матрицы в симметричную (копирование верхней правой части в нижнюю левую)
function make_matrix_symmetric(matrix)
  for i in 1:(size(matrix, 1) - 1) 
    for j in (i + 1):size(matrix, 1)
      if (matrix[i, j] != matrix[j, i])
        matrix[j, i] = matrix[i, j]
      end
    end
  end
end

# --------------
# Основная часть
# --------------

# 5x5
# matrix_file = "resources/little_matrix.csc"
# vector_file = "resources/little_vector.csc"

# 468x468
# matrix_file = "resources/nos5.csc"
# vector_file = "resources/nos5_vector.csc"

# 1074x1074
# matrix_file = "resources/bcsstk08.csc"
# vector_file = "resources/bcsstk08_vector.csc"

# 1473x1473
# matrix_file = "resources/bcsstk12.csc"
# vector_file = "resources/bcsstk12_vector.csc"

# 2003x2003
# matrix_file = "resources/bcsstk13.csc"
# vector_file = "resources/bcsstk13_vector.csc"

# 10974x10974
matrix_file = "resources/bcsstk17.csc"
vector_file = "resources/bcsstk17_vector.csc"


# Реализация метода сопряжённых градиентов
function gradients(matrix, vector)
  println("epsilon: ", eps)
  global vector_x = Array{Float64,1}(zeros(length(vector_b)))
  global vector_r = vector_b - (matrix_A * vector_x)
  global vector_z = vector_r

  if (info)
    println("vector_b: ", vector_b)
    println("matrix_A: ", matrix_A)
    println("vector_x0: ", vector_x)
    println("vector_r0: ", vector_r)
    println("vector_z0: ", vector_z)
  end

  global i = 1
  while (eps < (abs(norm(vector_r)) / abs(norm(vector_b))))
    local vector_xp = vector_x
    local vector_rp = vector_r
    local vector_zp = vector_z
    mv1 = matrix_A * vector_zp
    alpha = (transpose(vector_rp) * vector_rp) / (transpose(mv1) * vector_zp)
    if (debug) println("alpha[", i, "]: ", alpha) end
    global vector_x = vector_xp + alpha * vector_zp
    if (debug) println("vector_x[", i, "]: ", vector_x) end
    global vector_r = vector_rp - alpha * (mv1)
    if (debug) println("vector_r[", i, "]: ", vector_r) end
    if (debug) println("vector_rm[", i, "]: ", vector_rp) end
    beta = (transpose(vector_r) * vector_r) / (transpose(vector_rp) * vector_rp)
    if (debug) println("beta[", i, "]: ", beta) end
    global vector_z = vector_r + beta * vector_zp
    if (debug) println("vector_z[", i, "]: ", vector_z) end
    if (process)
      println("[#", i, "] alpha: ", alpha)
      println("[#", i, "] beta: ", beta)
      print("[#", i, "] vector x: ")
      print_vector(vector_x, eps)
      println()
    end
    global i += 1
  end

  println("Total iterations: ", i - 1)
  print("x: ")
  print_vector(vector_x)
end

# Реализация метода сопряжённых градиентов с использованием параллельных вычислений
function gradients_parallel(matrix, vector)
  println("epsilon: ", eps)
  global vector_x = Array{Float64,1}(zeros(length(vector_b)))
  global vector_r = vector_b - matrix_A * vector_x
  global vector_z = vector_r

  if (info) 
    println("vector_b: ", vector_b)
    println("matrix_A: ", matrix_A)
    println("vector_x0: ", vector_x)
    println("vector_r0: ", vector_r)
    println("vector_z0: ", vector_z)
  end

  global i = 1
  while (eps < (abs(norm(vector_r)) / abs(norm(vector_b))))
    local vector_xp = vector_x
    local vector_rp = vector_r
    local vector_zp = vector_z
    local mv1 = mv_multiply(matrix_A, vector_zp)
    # local mv1 = matrix_A * vector_zp
    alpha = s_multiply(vector_rp, vector_rp) / s_multiply(mv1, vector_zp)
    if (debug) println("alpha[", i, "]: ", alpha) end
    global vector_x = vector_xp + alpha * vector_zp
    if (debug) println("vector_x[", i, "]: ", vector_x) end
    global vector_r = vector_rp - alpha * mv1
    if (debug) println("vector_r[", i, "]: ", vector_r) end
    if (debug) println("vector_rm[", i, "]: ", vector_rp) end
    beta = s_multiply(vector_r, vector_r) / s_multiply(vector_rp, vector_rp)
    if (debug) println("beta[", i, "]: ", beta) end
    global vector_z = vector_r + beta * vector_zp
    if (debug) println("vector_z[", i, "]: ", vector_z) end
    if (debug) println() end
    if (process)
      println("[#", i, "] alpha: ", alpha)
      println("[#", i, "] beta: ", beta)
      print("[#", i, "] vector x: ")
      print_vector(vector_x, eps)
      println()
    end
    global i += 1
  end

  println("Total iterations: ", i - 1)
  print("x: ")
  print_vector(vector_x)
end

matrix_A = read_csc_matrix(matrix_file)
vector_b = read_csc_vector(vector_file)

println("Матрица ", matrix_file)

if !is_matrix_symmetric(matrix_A)
  println("Корректируем матрицу - добиваемся симметрии")
  make_matrix_symmetric(matrix_A)
end

t_start = now()
@time gradients(matrix_A, vector_b)
t_end = now()
println("gradients(): ", t_end - t_start)

# t_start = now()
# @time gradients_parallel(matrix_A, vector_b)
# t_end = now()
# println("gradients_parallel(): ", t_end - t_start)
