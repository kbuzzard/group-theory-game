import orbit.orbit_stabilizer

namespace mygroup

open classical function set mygroup.subgroup mygroup.group
variables {G : Type} [group G]

def normalizer' (H : subgroup G) := stabilizer (conjugation_action) H

lemma mem_normalizer'_def  {H : subgroup G} (x : G) :
  x ∈ normalizer' H ↔ {k : G | ∃ (h : G) (H : h ∈ H), k = x * h * x⁻¹} = H := 
subgroup.ext'_iff.symm

lemma mem_normalizer'_iff {H : subgroup G} (x : G):
  x ∈ normalizer' H ↔ ∀ k : G, k ∈ H ↔ x * k * x⁻¹ ∈ H := 
begin
  rw mem_normalizer'_def,
  split,
  { intros hx s,
    rw ext_iff at hx,
    specialize hx (x * s *x⁻¹) ,
    dsimp at hx,
    rw mem_coe' at hx,
    rw ← hx,
    split,
    { rintro hs, use [s, hs] },
    { rintro ⟨h, hh, hsx⟩,
      convert hh,
      apply mul_left_cancel x, 
      apply mul_right_cancel x⁻¹,
      assumption } },
    { intro hx,
      ext y,
      split,
      { rintro ⟨s, hs, rfl⟩, exact ( hx s ).1 hs},
      { intro hy,
        use x⁻¹ * y * x,
        split,
          { change y ∈ H at hy,
            convert (hx (x⁻¹ * y * x)).2 _,
            convert hy,
            simp [group.mul_assoc] },
          { simp [group.mul_assoc] } } }
end  


lemma normalizer'_eq_set_normalizer (H : subgroup G) : 
  (normalizer' H  : set G) = { g : G | ∀ n, n ∈ H ↔ g * n * g⁻¹ ∈ H } := 
by { ext, rw [subgroup.mem_coe', mem_normalizer'_iff], refl }

lemma normalizer_eq_normalizer' (H : subgroup G) : 
  normalizer H.carrier = normalizer' H :=
begin
  apply subgroup.ext'_iff.1,
  change (normalizer H.carrier).carrier = normalizer' H,
  rw normalizer'_eq_set_normalizer, refl,
end

lemma index_normalizer_congr_index_modp [fintype G] 
  {p : ℕ} (hp: p.prime) (H : subgroup G) (h: is_p_subgroup H p) :
  index' (normalizer (H : set G)) H ≡ index H [MOD p] := sorry

lemma normalizer_neq_subgroup [fintype G] 
  (H : subgroup G) {p : ℕ} (hp: p.prime) (h: is_p_subgroup H p) : 
  p ∣ index H → normalizer (H : set G) ≠ H := sorry

theorem sylow_one_part1 [fintype G] 
  {p m n: ℕ} {hp : p.prime} {hG : fincard' G = p ^ n * m} {hdiv : ¬ p ∣ m} : 
  ∀ (i ≤ n), ∃ H : subgroup G, fincard' H = p ^ i := sorry
-- and want to write that each of these subgroups of cardinality p^i is normal 
-- in a subgroup of cardinality p^(i+1)

end mygroup