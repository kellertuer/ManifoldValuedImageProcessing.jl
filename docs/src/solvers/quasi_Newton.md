# [Riemannian quasi-Newton methods](@id quasiNewton)

```@meta
    CurrentModule = Manopt
```

```@docs
    quasi_Newton
    quasi_Newton!
```

## Background

The aim is to minimize a real-valued function on a Riemannian manifold, i.e.

```math
\min f(x), \quad x \in \mathcal{M}.
```

Riemannian quasi-Newtonian methods are as generalizations of their Euclidean counterparts Riemannian line search methods. These methods determine a search direction ``η_k ∈ T_{x_k} \mathcal{M}`` at the current iterate ``x_k`` and a suitable stepsize ``α_k`` along ``\gamma(α) = R_{x_k}(α η_k)``, where ``R \colon T \mathcal{M} \to \mathcal{M}`` is a retraction. The next iterate is obtained by

```math
x_{k+1} = R_{x_k}(α_k η_k).
```

In quasi-Newton methods, the search direction is given by

```math
η_k = -{\mathcal{H}_k}^{-1}[∇ f (x_k)] = -\mathcal{B}_k [∇f (x_k)],
```

where ``\mathcal{H}_k \colon T_{x_k} \mathcal{M} \to T_{x_k} \mathcal{M}`` is a positive definite self-adjoint operator, which approximates the action of the Hessian ``\operatorname{Hess} f (x_k)[\cdot]`` and ``\mathcal{B}_k = {\mathcal{H}_k}^{-1}``. The idea of quasi-Newton methods is instead of creating a complete new approximation of the Hessian operator ``\operatorname{Hess} f(x_{k+1})`` or its inverse at every iteration, the previous operator ``\mathcal{H}_k`` or ``\mathcal{B}_k`` is updated by a convenient formula using the obtained information about the curvature of the objective function during the iteration. The resulting operator ``\mathcal{H}_{k+1}`` or ``\mathcal{B}_{k+1}`` acts on the tangent space ``T_{x_{k+1}} \mathcal{M}`` of the freshly computed iterate ``x_{k+1}``.
In order to get a well-defined method, the following requirements are placed on the new operator ``\mathcal{H}_{k+1}`` or ``\mathcal{B}_{k+1}`` that is created by an update. Since the Hessian ``\operatorname{Hess} f(x_{k+1})`` is a self-adjoint operator on the tangent space ``T_{x_{k+1}} \mathcal{M}``, and ``\mathcal{H}_{k+1}`` approximates it, we require that ``\mathcal{H}_{k+1}`` or ``\mathcal{B}_{k+1}`` is also self-adjoint on ``T_{x_{k+1}} \mathcal{M}``. In order to achieve a steady descent, we want ``η_k`` to be a descent direction in each iteration. Therefore we require, that ``\mathcal{H}_{k+1}`` or ``\mathcal{B}_{k+1}`` is a positive definite operator on ``T_{x_{k+1}} \mathcal{M}``. In order to get information about the cruvature of the objective function into the new operator ``\mathcal{H}_{k+1}`` or ``\mathcal{B}_{k+1}``, we require that it satisfies a form of a Riemannian quasi-Newton equation:

```math
\mathcal{H}_{k+1} [T_{x_k \rightarrow x_{k+1}}({R_{x_k}}^{-1}(x_{k+1}))] = ∇f(x_{k+1}) - T_{x_k \rightarrow x_{k+1}}(∇f(x_k))
```

or

```math
\mathcal{B}_{k+1} [∇f(x_{k+1}) - T_{x_k \rightarrow x_{k+1}}(∇f(x_k))] = T_{x_k \rightarrow x_{k+1}}({R_{x_k}}^{-1}(x_{k+1}))
```

where ``T_{x_k \rightarrow x_{k+1}} \colon T_{x_k} \mathcal{M} \to T_{x_{k+1}} \mathcal{M}`` and the chosen retraction ``R`` is the associated retraction of ``T``. We note that, of course, not all updates in all situations will meet these conditions in every iteration.
For specific quasi-Newton updates, the fulfilment of the Riemannian curvature condition, which requires that

```math
g_{x_{k+1}}(s_k, y_k) > 0
```

holds, is a requirement for the inheritance of the self-adjointness and positive definiteness of the ``\mathcal{H}_k`` or ``\mathcal{B}_k`` to the operator ``\mathcal{H}_{k+1}`` or ``\mathcal{B}_{k+1}``. Unfortunately, the fulfillment of the Riemannian curvature condition is not given by a step size ```\alpha_k > 0`` that satisfies the generalised Wolfe conditions. However, in order to create a positive definite operator ``\mathcal{H}_{k+1}`` or ``\mathcal{B}_{k+1}`` in each iteration, in [^HuangGallivanAbsil2015] the so-called locking condition was introduced, which requires that the isometric vector transport ``T^S``, which is used in the update formula, and its associate retraction ``R`` fulfill

```math
T^{S}{x, \xi_x}(\xi_x) = \beta T^{R}{x, \xi_x}(\xi_x), \quad \beta = \frac{\lVert \xi_x \rVert_x}{\lVert T^{R}{x, \xi_x}(\xi_x) \rVert_{R_{x}(\xi_x)}},
```

where ``T^R`` is the vector transport by differentiated retraction. With the requirement that the isometric vector transport ``T^S`` and its associated retraction ``R`` satisfies the locking condition and using the tangent vector

```math
y_k = {\beta_k}^{-1} ∇f(x_{k+1}) - T^{S}{x_k, α_k η_k}(∇f(x_k)),
```

where

```math
\beta_k = \frac{\lVert α_k η_k \rVert_{x_k}}{\lVert T^{R}{x_k, α_k η_k}(α_k η_k) \rVert_{x_{k+1}}},
```

in the update, it can be shown that choosing a stepsize ``α_k > 0`` that satisfies the Riemannian wolfe conditions leads to the fulfilment of the Riemannian curvature condition, which in turn implies that the operator generated by the updates is positive definite.
In the following we denote the specific operators in matrix notation and hence use ``H_k`` and ``B_k``, respectively.

## Direction Updates

In general there are different ways to compute a fixed [`AbstractQuasiNewtonUpdateRule`](@ref).
In general these are represented by

```@docs
AbstractQuasiNewtonDirectionUpdate
QuasiNewtonMatrixDirectionUpdate
QuasiNewtonLimitedMemoryDirectionUpdate
QuasiNewtonCautiousDirectionUpdate
```

## Hessian Update Rules

Using

```@docs
update_hessian!
```

the following update formulae for either ``H_{k+1}`` or `` B_{k+1}`` are available.

```@docs
AbstractQuasiNewtonUpdateRule
BFGS
DFP
Broyden
SR1
InverseBFGS
InverseDFP
InverseBroyden
InverseSR1
```

## Options

The quasi Newton algorithm is based on a [`GradientProblem`](@ref).

```@docs
QuasiNewtonOptions
```

## Literature