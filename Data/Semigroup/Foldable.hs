-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Semigroup.Foldable
-- Copyright   :  (C) 2011 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  provisional
-- Portability :  portable
--
----------------------------------------------------------------------------
module Data.Semigroup.Foldable
  ( Foldable1(..)
  , traverse1_
  , for1_
  , sequenceA1_
  , foldMapDefault1
  ) where

import Prelude hiding (foldr)
import Data.Foldable
import Data.Functor.Apply
import Data.Semigroup
import Data.Monoid

class Foldable t => Foldable1 t where
  fold1 :: Semigroup m => t m -> m
  foldMap1 :: Semigroup m => (a -> m) -> t a -> m

  foldMap1 f = maybe (error "foldMap1") id . getOption . foldMap (Option . Just . f) 
  fold1 = foldMap1 id

newtype Act f a = Act { getAct :: f a }

instance Apply f => Semigroup (Act f a) where
  Act a <> Act b = Act (a .> b)

instance Functor f => Functor (Act f) where
  fmap f (Act a) = Act (f <$> a)
  b <$ Act a = Act (b <$ a)

traverse1_ :: (Foldable1 t, Apply f) => (a -> f b) -> t a -> f ()
traverse1_ f t = () <$ getAct (foldMap1 (Act . f) t)
{-# INLINE traverse1_ #-}

for1_ :: (Foldable1 t, Apply f) => t a -> (a -> f b) -> f ()
for1_ = flip traverse1_
{-# INLINE for1_ #-}

sequenceA1_ :: (Foldable1 t, Apply f) => t (f a) -> f ()
sequenceA1_ t = () <$ getAct (foldMap1 Act t)
{-# INLINE sequenceA1_ #-}

-- | Usable default for foldMap, but only if you define foldMap1 yourself
foldMapDefault1 :: (Foldable1 t, Monoid m) => (a -> m) -> t a -> m
foldMapDefault1 f = unwrapMonoid . foldMap (WrapMonoid . f)
{-# INLINE foldMapDefault1 #-}

-- toStream :: Foldable1 t => t a -> Stream a
-- concat1 :: Foldable1 t => t (Stream a) -> Stream a
-- concatMap1 :: Foldable1 t => (a -> Stream b) -> t a -> Stream b