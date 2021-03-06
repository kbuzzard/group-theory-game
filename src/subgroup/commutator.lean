import subgroup.cyclic

/- In this file we will define the commutator and some lemmas about it. -/

namespace mygroup

open_locale classical

open mygroup.subgroup mygroup.quotient group_hom function set

variables {G : Type} [group G]

/-- The commutator of two elements `a`, `b` of a group `G` is `a * b * a⁻¹ * b⁻¹`-/
def commutator (a b : G) := a * b * a ⁻¹ * b⁻¹

@[simp] lemma commutator_def {a b : G} : commutator a b = a * b * a⁻¹ * b⁻¹ := rfl

def commutators (G : Type) [group G] := { c | ∃ a b : G, c = commutator a b }

@[simp] lemma commutators_def : commutators G = 
  { c | ∃ a b : G, c = commutator a b } := rfl

@[simp] lemma mem_commutators_iff (x : G) : x ∈ commutators G ↔ 
  ∃ a b : G, x = commutator a b := iff.rfl

-- To show that the subgroup generated by the set of commutators is normal, we 
-- first need a more general lemma for showing normal'ness' of closures, i.e. 
-- the fact that the closure is normal if the set is closed under conjugation

-- We will use the induction principle on closure of subgroups

namespace subgroup

/-- The closure of an invariant set is also invariant under conjugation -/
lemma closure_normal {s : set G} (hs : ∀ t ∈ s, ∀ g : G, g * t * g⁻¹ ∈ s) : 
  ∀ t ∈ closure s, ∀ g : G, g * t * g⁻¹ ∈ closure s := 
begin
  intros t ht g,
  apply closure_induction ht,
    exact λ x hx, le_closure _ (hs x hx g),
    simp [one_mem],
    intros x y hx hy,
    conv_lhs 
      { congr, congr, skip, congr, 
        rw [show x = x * g⁻¹ * g, by simp [group.mul_assoc]] },
    rw [show g * (x * g⁻¹ * g * y) * g⁻¹ = g * x * g⁻¹ * (g * y * g⁻¹), 
        by simp [group.mul_assoc]],
    refine mul_mem _ hx hy,
    intros x hx, refine (inv_mem_iff _).1 _,
    simpa [← group.mul_assoc],
end

/-- The commutator is the normal subgroup generated by the set of commutators -/
def commutator_normal (G : Type) [group G] : normal G := 
{ conj_mem' := 
  begin
    intros n hn g,
    refine closure_normal _ _ hn _,
    rintro t ⟨a, b, rfl⟩ g,
    rw [commutator_def, show g * (a * b * a⁻¹ * b⁻¹) * g⁻¹ = 
          g * a * g⁻¹ * (g * b * g⁻¹) * (g * a * g⁻¹)⁻¹ * (g * b * g⁻¹)⁻¹, 
          by simp [group.mul_assoc]],
    exact ⟨g * a * g⁻¹, (g * b * g⁻¹), rfl⟩,
  end .. closure $ commutators G }

/-- A group `G` the abelian if and only if the commutator subgroup is `{1}`-/
lemma comm_group_iff : (commutator_normal G : set G) = {1} ↔ @commutative G (*) :=
begin
  split, intros h a b,
    { change (closure (commutators G) : set G) = _ at h,
      have : {c : G | ∃ (a b : G), c = commutator a b} = {1},
        apply subset.antisymm, rw ← h, exact le_closure _,
        rw singleton_subset_iff, exact ⟨a, a⁻¹, by simp⟩,
      rw eq_singleton_iff_unique_mem at this,
      rw [← group.mul_right_cancel_iff (a⁻¹ * b⁻¹),
          (this.right (a * b * (a⁻¹ * b⁻¹)) 
          ⟨a, b, by simp [group.mul_assoc]⟩).symm],
      simp [group.mul_assoc] },
    { intros h, apply subset.antisymm,
      { change closure (commutators G) ≤ trivial,
        rw closure_le, rintro _ ⟨a, b, rfl⟩, rw [commutator_def, h a b, mem_coe'], 
        simp [group.mul_assoc, subgroup.trivial, ← mem_coe] },
      { intros x hx, rw mem_singleton_iff at hx, subst hx, exact one_mem _ } }
end

lemma comm_group_iff' : (commutator_normal G : subgroup G) = ⊥ ↔ 
  @commutative G (*) :=
begin
  rw ← comm_group_iff, 
  split; intro h,
    { change (commutator_normal G).carrier = _,
      change (commutator_normal G).to_subgroup = _ at h,
      rw [h, bot_eq_trivial], refl },
    { apply ext', rw bot_eq_trivial, exact h }
end

lemma commutator_normal_eq_bot_iff : 
  (commutator_normal G : subgroup G) = ⊥ ↔ commutators G = {1} :=
begin
  change closure (commutators G) = _ ↔ _,
  rw eq_bot_iff,
  split; intro h,
    { ext, split; intro hx,
        { change x ∈ subgroup.trivial.carrier,
          rw ← bot_eq_trivial,
          exact h (le_closure _ hx) },
        { exact hx.symm ▸ ⟨1, 1, by simp⟩ } },
    { rw [closure_le, h],
      intros x hx, rw mem_singleton_iff at hx,
      subst hx, exact one_mem _ }
end

/-- Given the group homomorphism `f : G → H` where `H` is a abelian, for all `x`
  in the commutators of `G`, `f x = 1` -/
lemma map_commutators_eq_one {H : Type} [comm_group H] (f : G →* H) : 
  ∀ x ∈ commutators G, f x = 1 :=
begin
  intros x hx,
  rw mem_commutators_iff at hx,
  rcases hx with ⟨a, b, rfl⟩,
  simp [group.mul_comm],
end

lemma closure_eq_kernel_of_map_eq_one {H : Type} [group H] 
  {f : G →* H} {S : set G} (hS : ∀ s ∈ S, f s = 1) : closure S ≤ kernel f :=
begin
  intros x hx,
  erw mem_closure_iff at hx,
  specialize hx (comap f ⊥) _,
  rw mem_comap' at hx,
  change f x = 1,
  rw [← mem_singleton_iff, ← bot_eq_singleton_one],
  exact hx,
  intros s hs,
  erw mem_comap', 
  rw mem_bot_iff,
  exact hS s hs,
end

lemma map_le_iff_le_comap {H : Type} [group H] 
  {f : G →* H} {S : subgroup G} {T : subgroup H} : 
  map f S ≤ T ↔ S ≤ comap f T := 
begin
  split; intro h,
    { intros x hx, erw mem_comap',
      apply h, erw mem_map,
      refine ⟨x, hx, rfl⟩ },
    { intros x hx, 
      erw mem_map at hx,
      rcases hx with ⟨y, hy, rfl⟩,
      erw ← mem_comap',
      exact h hy }
end

lemma kernel_eq_comap_bot {H : Type} [group H] (f : G →* H) : 
  (kernel f : subgroup G) = comap f ⊥ := 
by ext; erw [mem_kernel, ← mem_bot_iff, mem_comap']

lemma map_commutator_normal_le_bot {H : Type} [comm_group H] (f : G →* H) : 
  map f (commutator_normal G) ≤ ⊥ := 
begin
  rw map_le_iff_le_comap,
  convert closure_eq_kernel_of_map_eq_one (map_commutators_eq_one f),
  exact (kernel_eq_comap_bot f).symm
end

end subgroup

-- Disadvantage with using bundled normal: we don't have a lattice structure for 
-- normal subgroups

-- ⊢ commutators G ⊆ ↑N ↔ commutators (G /ₘ N) = {1}
-- Consider mk : G → G /ₘ N is a surjective homomorphism with the kernel N,
-- so the goal is saying the commutators is in the kernel iff the 
-- commutators of G /ₘ N  is 1, i.e. we need to show that 
-- commutators (G /ₘ N) ⊆ quotient.mk N '' commutators G 
lemma quotient.comm_iff_commutators_subset (N : normal G) : 
  commutators G ⊆ N ↔ @commutative (G /ₘ N) (*) :=
begin
  rw [← subgroup.comm_group_iff', subgroup.commutator_normal_eq_bot_iff],
  have : commutators (G /ₘ N) ⊆  quotient.mk N '' commutators G,
    rintro x ⟨a, b, rfl⟩,
    rcases exists_mk a with ⟨a, rfl⟩,
    rcases exists_mk b with ⟨b, rfl⟩,
    exact ⟨commutator a b, ⟨a, b, rfl⟩, rfl⟩,
  conv_lhs { rw ← @kernel_mk _ _ N },
  split; intro h,
    { apply subset.antisymm,
        { refine subset.trans this (λ _ hx, _),
          rcases hx with ⟨x, hx, rfl⟩, 
          rw [mem_singleton_iff, ← mem_kernel],
          exact h hx },
        { intros x hx,
          rw mem_singleton_iff at hx,
          rw hx, exact ⟨1, 1, by simp⟩ } },
    { rintro _ ⟨a, b, rfl⟩,
      change _ ∈ (mk N).kernel,
      rw [mem_kernel, ← mem_singleton_iff, ← h],
      exact ⟨a, b, rfl⟩ }
end

/-- For all `N : normal G`, if it contains the comutator subgroup, then 
  `G /ₘ N` is abelian. -/
theorem quotient.comm_iff_commutators_le (N : normal G) : 
  subgroup.commutator_normal G ≤ N ↔ @commutative (G /ₘ N) (*) := 
show closure (commutators G) ≤ _ ↔ _, 
  by rw [← quotient.comm_iff_commutators_subset, closure_le]; refl

/-- A subgroup is normal if it comatins the commutators -/
def normal.of_subset_commutators (H : subgroup G) (hH : commutators G ⊆ H) := 
  normal.of_subgroup H 
begin
  intros n hn g, 
  rw [show g * n * g⁻¹ = g * n * g⁻¹ * n⁻¹ * n, by simp [group.mul_assoc]],
  exact mul_mem _ (hH ⟨g, n, rfl⟩) hn
end

def group.comm_group_of (G : Type) [group G] (hG : @commutative G (*)) : 
  comm_group G := { mul_comm := hG, .. ‹group G› }

/-- The Abelianization of a group is the group quotiented out by its commutator
  normal subgroup -/
def abelianization (G : Type) [group G] := G /ₘ subgroup.commutator_normal G

-- The Abelianization of a group is commutative
instance := group.comm_group_of (G /ₘ subgroup.commutator_normal G) 
  ((quotient.comm_iff_commutators_subset _).1 (le_closure _))

namespace abelianization

variables {H : Type} [comm_group H]

def lift (f : G →* H) := quotient.lift f (subgroup.commutator_normal G)
begin
  convert subgroup.map_le_iff_le_comap.1  
    (subgroup.map_commutator_normal_le_bot f),
  exact subgroup.kernel_eq_comap_bot f
end

@[simp] lemma lift_def (f : G →* H) : 
  (lift f ∘* quotient.mk (subgroup.commutator_normal G)) = f := by ext; refl

/-- The universal property of Abelianization of Groups -/
lemma lift.exists_unique (H : Type) [comm_group H] (f : G →* H) : 
  ∃! F : (G /ₘ subgroup.commutator_normal G) →* H, 
  f = (F ∘* quotient.mk (subgroup.commutator_normal G)) :=
⟨abelianization.lift f, by simp, by rintros F rfl; tidy⟩

end abelianization

end mygroup