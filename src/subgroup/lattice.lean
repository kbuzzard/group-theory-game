import subgroup.definitions

/-
Let G be a group. The type of subgroups of G is `subgroup G`. 
In other words, if `H : subgroup G` then H is a subgroup of G. 
The three basic facts you need to know about H are:

H.one_mem : (1 : G) ∈ H
H.mul_mem {x y : G} : x ∈ H → y ∈ H → x * y ∈ H
H.inv_mem {x : G} : x ∈ H → x⁻¹ ∈ H

Subgroups of a group form what is known as a *lattice*. 
This is a partially ordered set with a sensible notion of
max and min (and even sup and inf). 

We will prove this here.
-/

namespace mygroup

open group set

variables {G : Type} [group G]
variables {H K : subgroup G}

namespace subgroup

-- The intersect of two subgroups is also a subgroup
def inf (H K : subgroup G) : subgroup G :=
{ carrier := H.carrier ∩ K.carrier,
  one_mem' := ⟨H.one_mem, K.one_mem⟩,
  mul_mem' := λ _ _ ⟨hhx, hkx⟩ ⟨hhy, hky⟩, 
  ⟨H.mul_mem hhx hhy, K.mul_mem hkx hky⟩,
  inv_mem' := λ x ⟨hhx, hhy⟩,
  ⟨H.inv_mem hhx, K.inv_mem hhy⟩}

instance : has_inf (subgroup G) := ⟨inf⟩

lemma mem_inf (H K : subgroup G) (g : G) : 
  g ∈ H ⊓ K ↔ g ∈ H ∧ g ∈ K := iff.rfl

example (H K : subgroup G) : subgroup G := H ⊓ K

/- 
We will consider the closure of a set as the intersect of all subgroups
containing the set
-/
instance : has_Inf (subgroup G) :=
⟨λ s, {
  carrier := ⋂ t ∈ s, (t : set G),
  one_mem' := mem_bInter $ λ i h, i.one_mem,
  mul_mem' := λ x y hx hy, mem_bInter $ λ i h,
    i.mul_mem (by apply mem_bInter_iff.1 hx i h) 
    (by apply mem_bInter_iff.1 hy i h),
  inv_mem' := λ x hx, mem_bInter $ λ i h,
    i.inv_mem (by apply mem_bInter_iff.1 hx i h) }⟩

variable {ι : Type*}

-- The intersect of a set of subgroups is a subgroup
def infi (H : ι → subgroup G) : subgroup G := 
{ carrier := ⋂ i, H i,
  one_mem' := mem_Inter.mpr $ λ i, (H i).one_mem,
  mul_mem' := λ _ _ hx hy, mem_Inter.mpr $ λ i, 
  by {rw mem_Inter at *, from mul_mem (H i) (hx i) (hy i)},
  inv_mem' := λ x hx, mem_Inter.mpr $ λ i, (H i).inv_mem $ by apply mem_Inter.mp hx }

def closure (S : set G) : subgroup G := Inf {H | S ⊆ H}

/- We will now prove some lemmas that are helpful in proving subgroups 
form a galois_insertion with the coercion to set-/

lemma le_closure (S : set G) : S ≤ closure S :=
λ s hs H ⟨y, hy⟩, by rw ←hy; simp; exact λ hS, hS hs

lemma closure_le (S : set G) (H : subgroup G) : closure S ≤ H ↔ S ≤ (H : set G) :=
begin
  split,
    { intro h, refine subset.trans (le_closure _) h },
    { intros h y,
      unfold closure, unfold Inf, 
      rw mem_bInter_iff, intro hy,
      exact hy H h,
    }
end

lemma closure_self {H : subgroup G} : closure (H : set G) = H :=
begin
  rw ←subgroup.ext'_iff, ext,
  split; intro hx,
    { apply subset.trans _ ((closure_le (H : set G) H).2 (subset.refl H)), 
      exact hx, exact subset.refl _
    },
    { apply subset.trans (le_closure (H : set G)), 
      intros g hg, assumption, assumption }
end

/-
Now, by considering the coercion between subgroup G → set G, we cheat a bit
by transfering the partial order on set to the partial order on subgroups.

We do this because galois_insertion requires preorders and partial orders
extends preoders.
-/
instance : partial_order (subgroup G) := 
{.. partial_order.lift (coe : subgroup G → set G) (λ x y, subgroup.ext')}

/-
Finially we prove that subgroups form a galois_insertion with the coercion 
to set.
-/
def gi : @galois_insertion (set G) (subgroup G) _ _ closure (λ H, H.carrier) :=
{ choice := λ S _, closure S,
  gc := λ H K,
  begin
    split; intro h,
      { exact subset.trans (le_closure H) h },
      { exact (closure_le _ _).2 h },
  end,
  le_l_u := λ H, le_closure (H : set G),
  choice_eq := λ _ _, rfl }

/-
With that it follows that subgroups form a complete lattice!
-/
instance : complete_lattice (subgroup G) :=
{.. galois_insertion.lift_complete_lattice gi}

-- scary example!
-- SL₂(ℝ) acts on the upper half plane {z : ℂ | Im(z) > 0}
-- (a b; c d) sends z to (az+b)/(cz+d)
-- check this is an action
-- so SL₂(ℤ) acts on the upper half plane
-- and H, the stabilizer of i ,is cyclic order 4
-- generated by (0 -1; 1 0)
-- and K, the stabilizer of e^{2 pi i/6}, is cyclic order 6
-- generated by something like (1 1; -1 0) maybe
-- Turns out that the smallest subgroup of SL₂(ℤ)
-- containing H and K is all of SL₂(ℤ)!
-- In particular if H and K are finite, but neither of
-- them are normal, then H ⊔ K can be huge

example (H K : subgroup G) : subgroup G := H ⊔ K

-- theorem: if K is normal in G then H ⊔ K is just 
-- literally {hk : h ∈ H, k ∈ K}
end subgroup

end mygroup
